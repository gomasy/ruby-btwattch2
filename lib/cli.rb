require "optparse"

module BTWATTCH2
  class CLI
    attr_reader :index, :addr, :interval, :timeout, :switch

    def initialize
      @opt = OptionParser.new
      @opt.on("-i", "--index <index>", "Specify adapter index, e.g. hci0."){|v|@index=v.to_i}
      @opt.on("-a", "--addr <addr>", "Specify the destination address."){|v|@addr=v}
      @opt.on("-n", "--interval <second(s)>", "Specify the seconds to wait between updates."){|v|@interval=v.to_i}
      @opt.on("-W", "--timeout <second(s)>", "Specify the time to wait for response."){|v|@timeout=v.to_i}
      @opt.on("--on", "Turn on the power switch"){|v|@switch="on"}
      @opt.on("--off", "Turn off the power switch"){|v|@switch="off"}
      @opt.parse(ARGV)

      @index = 0 if @index.nil?
      @interval = 1 if @interval.nil?
      @timeout = 3 if @timeout.nil?

      if !@addr.nil?
        @conn = Connection.new(self)
        main
      else
        help
      end
    end

    def help
      puts @opt
    end

    private
    def main
      if @switch.nil?
        @conn.measure
      else
        @conn.connect!
        eval("@conn.#{@switch}")
        @conn.disconnect!
      end
    end
  end
end
