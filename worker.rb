require 'json'
require 'faraday'
require 'time'

# read in commandline args
# Should be: worker_daemon {check for new job interval in s} {update status in s} {name}
if ARGV[0] != nil && ARGV[1] != nil && ARGV[2] != nil
  new_job_check_interval = ARGV[0].to_i
  update_interval = ARGV[1].to_i
  name = ARGV[2]
else
  puts "Usage: rbga_worker [new_job_check_interval] [update_interval] [name]"
  exit
end

puts "#{new_job_check_interval} #{update_interval} #{name}"

# This will be the update/heartbeat thread
t = Thread.new do 
  while true
    sleep update_interval 
    puts "knock knock"
  end   
end

# while we don't have a job, keep checking for a new one
while true
  sleep new_job_check_interval
  # check for job
  # if we get a new job run it
  puts "hello"
end

# do we ever need to join the thread back? If we exit, who cares?
t.join
