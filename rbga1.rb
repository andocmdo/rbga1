require 'json'
require 'time'

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

###### Load config and set globals ######

# We need to know the time interval
start_date = Time.strptime(config["inputData"]["startDate"], "%Y-%m-%d")
end_date = Time.strptime(config["inputData"]["endDate"], "%Y-%m-%d") + 86399

puts "Start date: #{start_date} \tEnd Date: #{end_date}"

## hopefully the records_hash is kept in order, (which I believe it is in modern versions of Ruby)
## So we will start at the beginning of the list, and check for the first included record and note the index
## NOPE, changed my mind. We will load them into an array and sort them
records_array = Array.new

records_hash.each do |key, sub_hash|
  this_record_timestamp = Time.strptime(key, "%Y-%m-%d")
  if this_record_timestamp >= start_date && this_record_timestamp <= end_date
    sub_hash["date"] = key
    sub_hash["timestamp"] = Time.strptime(key, "%Y-%m-%d").to_i
    records_array << sub_hash
    #puts sub_hash
  end
end

puts "Found and loaded #{records_array.size} records."

records_array.each do |record|
  print "#{record["date"]} "
end

puts "Sorting array..."
records_array.sort! {|a, b| a["timestamp"] <=> b["timestamp"]}

puts "Sorted array: "
records_array.each do |record|
  print "#{record["date"]} "
end

