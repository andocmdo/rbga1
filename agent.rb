class Agent
  attr_reader :fitness
  attr_accessor :genes

  def initialize(params = {})
    @genes = []
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
    other
  end

  def mutate(rate)
    # idea: maybe the gene classes could generate their own values
    # so we call mutate on the gene, maybe not the agent.
    # that way the agent doesn't need to know anything about the genes, it can be more general?
    self
  end

end

class SimpleMaxAgent < Agent
  def initialize(params = {})
    super
    @number_of_genes = params["number_of_genes"]
    @possible_actions = ["b", "s", "h"]
    @number_of_genes.times do
      @genes << @possible_actions.sample
    end
  end

  def xover(other)
    child = SimpleMaxAgent.new({"number_of_genes" => other.genes.size})
    xover_splice_index = (@genes.size * rand).to_i
    @genes.each_with_index do |gene, index|
      if index < xover_splice_index
        child.genes[index] = @genes[index]
      else
        child.genes[index] = other.genes[index]
      end
    end
    child
  end

end
