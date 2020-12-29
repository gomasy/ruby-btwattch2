module BTWATTCH2
  class CRC8
    POLYNOMIAL = 0x85

    class << self
      def crc1(crc, times = 0)
        return crc if times >= 8

        if crc & 0x80 == 0x80
          crc1((crc << 1 ^ POLYNOMIAL) & 0xff, times + 1)
        else
          crc1(crc << 1, times + 1)
        end
      end

      def crc8(payload)
        chr = payload.inject(0x00) do |x, y|
          crc1(y & 0xff ^ x)
        end

        [chr].pack("C*")
      end
    end
  end
end
