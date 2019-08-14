class Agent
  attr_reader :fitness
  attr_accessor :genes

  def initialize(params = {})
    @fitness = 0.0
  end

  def run_sim(records)
    # TODO FIXME
    @fitness = rand
  end

  def total_value
    # TODO FIXME
    @fitness * 100
  end

  def xover(other)
    child = Agent.new()
    xover_splice_index = (@genes.size * rand).to_i
    @genes.each_with_index do |gene, index|
      if index < xover_splice_index
        child.genes << @genes[index]
      else
        child.genes << other.genes[index]
      end
    end
  end

  def mutate(rate)
    # idea: maybe the gene classes could generate their own values
    # so we call mutate on the gene, maybe not the agent.
    # that way the agent doesn't need to know anything about the genes, it can be more general?
    
  end

end

class SimpleMaxAgent < Agent
  def initialize(params = {})
    super
    @genes_length = params.fetch(:genes_length, 10)
    
  end
end
