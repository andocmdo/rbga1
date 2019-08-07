require 'json'

if ARGV[0] != nil && ARGV[1] != nil
  config = JSON.parse(File.read(ARGV[0]))
  records_hash = JSON.parse(File.read(ARGV[1]))['Time Series (Daily)']
else
  puts "Usage: ruby rbga1.rb [configFile.json] [dataFile.json]"
  exit
end

# The way to parse the date and make an integer timestamp for the last second of that day
# since more records may exist in the future in the database at hourly/minute intervals earlier in the day 
# Time.strptime(key, "%Y-%m-%d").to_i + 86399
