require "optparse"

module BTWATTCH2
  class CLI
    attr_reader :index, :addr, :interval, :switch
    attr_accessor :conn

    def initialize
      @opt = OptionParser.new
      @opt.on("-i", "--index <index>", "Specify adapter index, e.g. hci0."){|v|@index=v.to_i}
      @opt.on("-a", "--addr <addr>", "Specify the destination address."){|v|@addr=v}
      @opt.on("-n", "--interval <second(s)>", "Specify the seconds to wait between updates."){|v|@interval=v.to_i}
      @opt.on("--on", "Turn on the power switch."){|v|@switch="on"}
      @opt.on("--off", "Turn off the power switch."){|v|@switch="off"}
      @opt.parse(ARGV)

      @index = 0 if @index.nil?
      @interval = 1 if @interval.nil?
    end

    def help
      puts @opt
    end

    def main
      @conn = Connection.new(self)
      @conn.connect!

      if @switch.nil?
        @conn.measure
      else
        eval("@conn.#{@switch}")
      end

      @conn.disconnect!
    rescue SignalException
      @conn.disconnect!
      exit
    end
  end
end
