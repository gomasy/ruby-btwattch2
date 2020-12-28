require "./lib/cli.rb"
require "./lib/connection.rb"

cli = BTWATTCH2::CLI.new do |opt|
  opt.on("--metric-name <name>", "Specify the metric name.") do |v|
    @name = v
  end
end

if cli.addr.nil? || @name.nil?
  cli.help
  exit
end

conn = BTWATTCH2::Connection.new(cli)
conn.subscribe_measure! do |e|
  puts "#{@name}.voltage\t#{e[:voltage]}\t#{e[:timestamp].to_i}"
  puts "#{@name}.ampere\t#{e[:ampere]}\t#{e[:timestamp].to_i}"
  puts "#{@name}.wattage\t#{e[:wattage]}\t#{e[:timestamp].to_i}"
  exit
end

while true do
  conn.write!(BTWATTCH2::PAYLOAD_MONITORING)
  sleep 1
end
