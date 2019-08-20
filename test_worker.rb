require 'json'
require 'faraday'
require 'time'
require 'daemons'
require 'socket'

@update_interval = 3
@server_url = "http://192.168.1.79:3000"

# first argument is the server base url, ex: http://192.168.1.231:3000
resp = Faraday.get("#{@server_url}/workers.json")
workers_list_json = JSON.parse(resp.body)

# now get our ip address
our_ip = nil
addr_list = Socket.ip_address_list
addr_list.each do |addr|
  our_ip = addr.ip_unpack[0] if addr.ip_unpack[0].start_with?("192.168.1.")
end
exit 99 if !our_ip

our_workers_hash_list = []
workers_list_json.each do |worker_entry|
  our_workers_hash_list << worker_entry if worker_entry["ipaddr"] == our_ip
end
exit 98 if our_workers_hash_list.empty?

our_workers = []
our_workers_hash_list.each do |worker_entry|
  our_workers << Daemons.run_proc(worker_entry["name"]) do
    ##### THIS IS THE WORKER PROCESS HERE ####
    # background daemonized process
    # This will be the update/heartbeat thread
    worker_id = worker_entry["id"]
    working = false
    # heartbeat thread
    t = Thread.new do
      while true
        sleep @update_interval
        # update server about worker status
        update_payload = {"online": true, "working": working, "last_seen": Time.now}.to_json
        worker_update_url = "#{@server_url}/workers/#{worker_id}"
        #puts "update worker"
        resp = Faraday.put(request_url, update_payload, "Content-Type" => "application/json")
        if working
          # update the job here
          # need the job id!!!!
          #job_update_url = "#{@server_url}/job/#{}"
          #resp = Faraday.put(request_url, update_payload, "Content-Type" => "application/json")
        end
      end
    end

    # while we don't have a job, keep checking for a new one
    loop do
      sleep @update_interval + 1 # this is dumb but whatever
      # check for job
      resp = Faraday.get("#{@server_url}/jobs/next?id=#{worker_id}")
      # if we get a new job run it
      if resp.status == 200
        # request was good
        # get the config from the server
        resp_json = JSON.parse(resp.body)   ## but what if there are no jobs and it sent back empty json {}??/
        job_id = resp_json["id"]
        request_url = "#{@server_url}/job_configs/#{resp_json["job_config_id"]}.json"
        config = JSON.parse(Faraday.get(reqeust_url))

        # get the data:
        # Fix this TODO
        records_hash = JSON.parse(File.read("/home/andocmdo/cluster/stocks/alphavantage/raw-json/TQQQ-2019-8-12-full.json"))['Time Series (Daily)']

        working = true
  end
end
