module BTWATTCH2
  class Payload
    CMD_HEADER = "\xAA"
    RTC_TIMER = "\x01"
    MONITORING = "\x08"
    TURN_ON = "\xA7\x01"
    TURN_OFF = "\xA7\x00"

    class << self
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
          char(CMD_HEADER),
          char(size(payload)),
          char(payload),
          char(BTWATTCH2::CRC8.crc8(payload))
        ].flatten.pack("C*")
      end

      def size(payload)
        [payload.size].pack("N*")
      end

      private
      def char(payload)
        payload.unpack("C*")
      end
    end
  end
end
