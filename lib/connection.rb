require "ble"

module BTWATTCH2
  SERVICE = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
  C_TX = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
  C_RX = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

  class Connection
    def initialize(cli)
      @cli = cli
      @device = BLE::Adapter.new("hci#{@cli.index}")[@cli.addr]
      @buf = ""
    end

    def connect!
      STDERR.print "[INFO] Connecting to #{@cli.addr} via hci#{@cli.index}..."
      @device.connect
      STDERR.puts " done"
    end

    def disconnect!
      @device.disconnect
      STDERR.puts "[INFO] Disconnected"
    end

    def set_rtc!(time)
      subscribe!(Payload::rtc(time)) do |e|
        if e.unpack("C*")[4] == 0x00
          STDERR.puts "[INFO] RTC set succeeded"
        end
        exit
      end
    end

    def subscribe!(payload)
      @device.subscribe(SERVICE, C_RX) do |v|
        if !@buf.empty? && v.unpack("C*")[0] == 0xAA
          @buf = ""
        end
        @buf += v

        if @buf.size - 4 == @buf[1..2].unpack("n*")[0]
          yield(@buf)
        end
      end

      while true
        write!(payload)
        sleep @cli.interval
      end
    end

    def subscribe_measure!
      subscribe!(Payload::monitoring) do |v|
        yield(read_measure)
      end
    end

    def write!(payload)
      @device.write(SERVICE, C_TX, payload)
    rescue DBus::Error => e
      if e.name == "org.bluez.Error.Failed"
        connect!
        retry
      end
    rescue NoMethodError
      retry
    end

    def read_measure
      date = @buf[23..28].unpack("C*").reverse

      {
        :voltage => ulong(@buf[5..10]).to_f / (16 ** 6).to_f,
        :ampere => ulong(@buf[11..16]).to_f / (32 ** 6).to_f,
        :wattage => ulong(@buf[17..22]).to_f / (16 ** 6).to_f,
        :timestamp => Time.new(1900 + date[0], date[1] + 1, date[2], date[3], date[4], date[5])
      }
    end

    def measure
      subscribe_measure! do |e|
        puts "V = #{e[:voltage]}, A = #{e[:ampere]}, W = #{e[:wattage]}"
      end
    end

    def on
      power("on")
    end

    def off
      power("off")
    end

    def blink_led
      subscribe!(Payload::blink_led) do |e|
        if e.unpack("C*")[4] == 0x00
          STDERR.puts "[INFO] Blink succeeded"
        end
        exit
      end
    end

    private
    def power(op)
      subscribe!(eval("Payload::#{op}")) do |e|
        e = e.unpack("C*")

        if e[5] == (op == "on" ? 0x01 : 0x00) && e[4] == 0x00
          STDERR.puts "[INFO] Power #{op} succeeded"
        else
          STDERR.puts "[ERR] Power #{op} failed, CODE: #{e[4]}"
        end

        exit
      end
    end

    def ulong(payload)
      (8 - payload.size).times do
        payload += "\x00"
      end

      payload.unpack("Q*")[0]
    end
  end
end
