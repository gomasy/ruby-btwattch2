require "./lib/cli.rb"
require "./lib/connection.rb"

cli = BTWATTCH2::CLI.new
if cli.addr.nil?
  cli.help
  exit
end

cli.main
