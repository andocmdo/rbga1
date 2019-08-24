require 'json'
require 'time'
require 'faraday'
require_relative 'agent.rb'
require_relative 'high_scores.rb'

if ARGV[0] != nil && ARGV[1] != nil
  config = JSON.parse(File.read(ARGV[0]))
  records_hash = JSON.parse(File.read(ARGV[1]))['Time Series (Daily)']
else
  puts "Usage: ruby rbga1.rb [configFile.json] [dataFile.json]"
  exit
end

# set the control for some janky debug printing...
debug = config["general"]["debug"]

# The way to parse the date and make an integer timestamp for the last second of that day
# since more records may exist in the future in the database at hourly/minute intervals earlier in the day
# Time.strptime(key, "%Y-%m-%d").to_i + 86399

###### Load config and set globals ######

# We need to know the time interval
start_date = Time.strptime(config["inputData"]["start_date"], "%Y-%m-%d")
end_date = Time.strptime(config["inputData"]["end_date"], "%Y-%m-%d") + 86399

puts "Start date: #{start_date} \tEnd Date: #{end_date}" if debug

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

puts "Found and loaded #{records_array.size} records." if debug

puts "Sorting records..." if debug
records_array.sort! {|a, b| a["timestamp"] <=> b["timestamp"]}

# Let's get started!
puts "Creating population." if debug
population_size = config["ga"]["population_size"]
population = Array.new
agent_params = config["agent"]
agent_params["number_of_genes"] = records_array.size
#puts agent_params
(0...population_size).each do
  population << SimpleMaxAgent.new(agent_params)  # It would be cool to choose differnt agents from the config file
end

stats = High_Scores.new(config["general"]["number_of_high_scores"])

# set the population parameters
mutation_rate = config["ga"]["mutation_rate"]
xover_pool_multiplier = config["ga"]["xover_pool_multiplier"]
xover_pool_min_bias = config["ga"]["xover_pool_min_bias"]
max_generations = config["ga"]["max_generations"]

# run the steps for the Genetic Algorithm
(0...max_generations).each do |generation|
  puts "\nGeneration: #{generation}" if debug   # TODO remove for debug

  # run agents through sim and calculate fitness
  population.each do |agent|
    agent.run_sim(records_array)    # run the agent through the simulation first
    stats.feed(agent)   #give to stats to check for high score
  end
  # feed that info to the stats tracker, who will then pull back out
  # the agents that have top scores
  # stats.feed_population(scores, population) # TODO might not be the most efficient way...
  stats.print_high_scores if debug

  # xover
  xover_pool = Array.new
  population.each do |agent|
    # add n number of agent copies to the mating pool according to xover_pool_multiplier
    # and always add at least xover_min_bias
    (0...((agent.fitness * xover_pool_multiplier).to_i + xover_pool_min_bias)).each do
      xover_pool << agent
    end
  end # xover pool filling loop end
  puts "Crossover pool size: #{xover_pool.size}" if debug

  # clear out the old population array, get ready to add children from xover pool
  population = Array.new
  (0...population_size).each do
    parentA = xover_pool[rand(xover_pool.size)]
    parentB = nil
    loop do
      parentB = xover_pool[rand(xover_pool.size)]
      break if !parentA.equal?(parentB)   # don't allow agent to xover with itself
    end
    population << parentA.xover(parentB)
  end # crossover loop

  # mutate
  population.each do |agent|
    agent.mutate(mutation_rate)
  end # end mutation loop
end # End generation/simulation loop

puts "\n\nSimulation Complete! Final stats:"
#stats.print_generations_summary
stats.print_high_scores_with_actions
#stats.print_high_scores_with_genes
