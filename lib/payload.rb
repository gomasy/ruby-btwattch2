module BTWATTCH2
  class Payload
    CMD_HEADER = [ 0xAA ]
    RTC_TIMER = [ 0x01 ]
    MONITORING = [ 0x08 ]
    TURN_OFF = [ 0xA7, 0x00 ]
    TURN_ON = [ 0xA7, 0x01 ]

    class << self
      def rtc(time)
        payload = [
          RTC_TIMER,
          time.sec,
          time.min,
          time.hour,
          time.day,
          time.mon - 1,
          time.year - 1900,
          time.wday
        ].flatten.pack("C*")

        generate(payload)
      end

      def monitoring
        generate(MONITORING)
      end

      def on
        generate(TURN_ON)
      end

      def off
        generate(TURN_OFF)
      end

      def generate(payload)
        [
          CMD_HEADER,
          char(size(payload)),
          payload,
          char(CRC8.crc8(payload))
        ].flatten.pack("C*")
      end

      def size(payload)
        [payload.size].pack("n*")
      end

      private
      def char(chr)
        chr.unpack("C*")
      end
    end
  end
end
