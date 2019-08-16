class High_Scores
  attr_accessor :num_high_scores
  attr_reader :high_score_agents, :min_high_score, :stats_per_gen_array

  def initialize(num_high_scores=10)
    @num_high_scores = num_high_scores  # number of top scoring agents to keep
    @high_score_agents = Array.new      # sorted array of top scoring agents
    @min_high_score = 0.0               # the minimum score in high_score_agents
    @stats_per_gen_array = Array.new    # array for each gen containing hash of descriptive statistics
  end

  def feed(agent)
    if (agent.fitness > @min_high_score) || (@high_score_agents.size < @num_high_scores)
      add_high_score_agent(agent)
    end
  end # feed end

  def feed_population(scores, population)
    #@stats_per_gen_array << scores.descriptive_statistics # this could be in a different process/thread/etc, no need
    # to slow down processing for this...
    # now check for high score entries
    scores.each_with_index do |score, index|
      # for each agent at index with some score, check if it is high enough
      # to enter into the high score agents list.
      if (score > @min_high_score) || (@high_score_agents.size < @num_high_scores)
        add_high_score_agent(population[index])
      end
    end #scores.each end
  end # feed end

  def add_high_score_agent(agent)
    if @high_score_agents.empty?  # if this is the first entry, nothing to compare to
      @high_score_agents << agent
    elsif (agent.fitness <= @min_high_score) && (@high_score_agents.size < @num_high_scores)
      @high_score_agents.push(agent)
    else
      @high_score_agents.each_with_index do |high_score_agent, index|
        if agent.fitness > high_score_agent.fitness
          @high_score_agents.insert(index, agent)
          # TODO someday we should check that an equal scoring, but genetically
          # different (although same exact action log) agent can be added without
          # being discarded because the score was the same as another "first-come"
          # Agent already on the high scores list...
          break
        end
      end # existing scores loop end
    end # if/else end
    # now if necessary remove the @num_high_scores + 1 item to keep us in limits
    if @high_score_agents.size > @num_high_scores
      @high_score_agents.pop
    end
    # and make sure min score is updated
    @min_high_score = @high_score_agents.last.fitness
  end # add_high_score_agent end

  # print each generations statistics
  def print_generations_summary
    @stats_per_gen_array.each_with_index do |stat, index|
      puts "Generation #{index}: #{stat}"
    end
  end

  def print_high_scores
    puts "High Scores"
    @high_score_agents.each_with_index do |agent, index|
      puts "   #{index}: Fitness (growth factor): #{agent.fitness} \tTotal value: $#{agent.total_value} "
    end
  end

  # print high scores
  def print_high_scores_with_actions
    puts "High Scores with Action log:"
    @high_score_agents.each_with_index do |agent, index|
      puts "#{index}: Fitness (growth factor): #{agent.fitness} \tTotal value: $#{agent.total_value} \n#{JSON.pretty_generate(agent.action_log)}"
    end
  end

  def print_high_scores_with_genes
    puts "High Scores with Genes:"
    @high_score_agents.each_with_index do |agent, index|
      puts "#{index}: #{agent.fitness.to_f} #{agent.total_value.to_f} \n#{JSON.pretty_generate(agent.genes_to_JSON)}\n"
    end
  end
end # class end
