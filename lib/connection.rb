require "ble"
require "date"

SERVICE = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
C_TX = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
C_RX = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

PAYLOAD_MONITORING = "\xAA\x00\x01\x08\xB3"
PAYLOAD_TURN_ON = "\xAA\x00\x02\xA7\x01\x59"
PAYLOAD_TURN_OFF = "\xAA\x00\x02\xA7\x00\xDC"

module BTWATTCH2
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

    def subscribe!
      @device.subscribe(SERVICE, C_RX) do |v|
        if !@buf.empty? && v.unpack("C*").first == 170
          @buf = ""
        end
        @buf += v

        if @buf.size == 31
          e = read
          puts "#{e[:voltage]} #{e[:ampere]} #{e[:wattage]}"
        end
      end
    end

    def write!(payload)
      Timeout.timeout(@cli.timeout) do
        begin
          @device.write(SERVICE, C_TX, payload)
        rescue DBus::Error => e
          STDERR.puts "[ERR] #{e}"
          sleep @cli.interval
          retry
        end
      end
    end

    def read
      date = @buf[23..28].unpack("C*").reverse

      {
        :voltage => @buf[5..11].unpack("I*").first.to_f / (16 ** 6).to_f,
        :ampere => @buf[11..17].unpack("I*").first.to_f / (32 ** 6).to_f,
        :wattage => @buf[17..23].unpack("I*").first.to_f / (16 ** 6).to_f,
        :timestamp => DateTime.new(1900 + date[0], date[1] + 1, date[2], date[3], date[4], date[5])
      }
    end

    def measure
      connect!
      subscribe!

      while true do
        write!(PAYLOAD_MONITORING)
        sleep @cli.interval
      end
    rescue DBus::Error, Timeout::Error => e
      STDERR.puts "[ERR] #{e}"
      sleep @cli.interval
      retry
    rescue SignalException
      disconnect!
      exit
    end

    def on
      write!(PAYLOAD_TURN_ON)
      STDERR.puts "[INFO] Power on succeeded"
    end

    def off
      write!(PAYLOAD_TURN_OFF)
      STDERR.puts "[INFO] Power off succeeded"
    end
  end
end
