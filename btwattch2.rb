require "./lib/cli.rb"
require "./lib/connection.rb"

cli = BTWATTCH2::CLI.new
if cli.addr
  cli.main
else
  cli.help
end
