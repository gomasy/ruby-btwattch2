require "optparse"
require "time"

module BTWATTCH2
  class CLI
    attr_reader :index, :addr, :interval, :switch, :time
    attr_accessor :conn

    def initialize
      @opt = OptionParser.new
      @opt.on("-i", "--index <index>", "Specify adapter index, e.g. hci0."){|v|@index=v.to_i}
      @opt.on("-a", "--addr <addr>", "Specify the destination address."){|v|@addr=v}
      @opt.on("-n", "--interval <second(s)>", "Specify the seconds to wait between updates."){|v|@interval=v.to_i}
      @opt.on("--on", "Turn on the power switch."){|v|@switch="on"}
      @opt.on("--off", "Turn off the power switch."){|v|@switch="off"}
      @opt.on("--set-rtc <time>", "Specify the time to set to RTC."){|v|@time=Time.parse(v)}
      @opt.on("--set-rtc-now", "Set the current time of this system to RTC."){|v|@time=Time.now}
      @opt.on("--test-led", "Blink the LED on the main unit."){|v|@switch="blink_led"}
      yield(@opt) if block_given?

      @opt.parse(ARGV)

      @index = 0 if @index.nil?
      @interval = 1 if @interval.nil?
    end

    def help
      puts @opt
    end

    def main
      @conn = Connection.new(self)

      if !@time.nil?
        @conn.set_rtc!(@time)
      elsif !@switch.nil?
        eval("@conn.#{@switch}")
      else
        @conn.measure
      end
    rescue SignalException
      @conn.disconnect!
      exit
    end
  end
end
