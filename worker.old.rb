require 'json'
require 'faraday'
require 'time'

# read in commandline args
# Should be: worker_daemon {check for new job interval in s} {update status in s} {name}
if ARGV[0] != nil && ARGV[1] != nil && ARGV[2] != nil
  @worker_id = ARGV[0].to_i
  @update_interval = ARGV[1].to_i
  @server_url = ARGV[2]
else
  puts "Usage: rbga_worker [worker_id] [update_interval] [server_url] "
  exit
end

# Set the intial values
@working = false

puts "#{@worker_id} #{@update_interval} #{@server_url}"

# This will be the update/heartbeat thread
t = Thread.new do
  while true
    sleep @update_interval
    # update server about worker status
    update_payload = {"online": true, "working": @working, "last_seen": Time.now}.to_json
    request_url = "#{@server_url}/workers/#{@worker_id}"
    puts "update worker"
    resp = Faraday.put(request_url, update_payload, "Content-Type" => "application/json")
    if @working
      puts "update job"
    end
  end
end

# while we don't have a job, keep checking for a new one
while true
  sleep @update_interval + 1 # this is dumb but whatever
  # check for job
  # if we get a new job run it
  puts "main loop"
end

# do we ever need to join the thread back? If we exit, who cares?
t.join
