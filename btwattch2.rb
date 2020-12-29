require "./lib/cli"
require "./lib/payload"
require "./lib/connection"
require "./lib/crc8"

cli = BTWATTCH2::CLI.new
if cli.addr.nil?
  cli.help
  exit
end

cli.main
