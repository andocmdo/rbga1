class Agent
  attr_reader :fitness, :settled_cash, :unsettled_cash, :action_log,
    :last_sale_action_index, :last_buy_action_index, :settle_interval
  attr_accessor :genes

  def initialize(params = {})
    @genes = []
    @fitness = 0.0
    @settled_cash = 0.00
    @unsettled_cash = 0.00
    @possible_actions = ["b", "s", "h"]
    @action_log = []
    @last_sale_action_index = 999999999
    @last_buy_action_index = 999999999
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
    # God the "number of genes" thing is super jank now. Fix this please... #TODO #FIXME
    @number_of_genes = params["number_of_genes"]
    @number_of_genes.times do
      @genes << @possible_actions.sample
    end
  end

  def run_sim(records)
    records.each_with_index do |record, index|
      # bookeeping first
      # must settle cash for past sell transactions, etc
      if @unsettled_cash > 0.0
        # check the time since last sell and settle cash if
        # it's over the time allowed (2 days?)
        if (index - @last_sale_action_index) > @settle_interval
          @settled_cash += @unsettled_cash
          @unsettled_cash = 0.0
        end
      end



    end
  end

  def total_value
    # TODO FIXME
    @fitness * 100
  end

  def xover(other)
    child = SimpleMaxAgent.new({"number_of_genes" => other.genes.size})
    xover_splice_index = (@genes.size * rand).to_i
    @genes.each_with_index do |_, index|
      if index < xover_splice_index
        child.genes[index] = @genes[index]
      else
        child.genes[index] = other.genes[index]
      end
    end
    child
  end

  def mutate(rate)
    @genes.each_with_index do |_, index|
      @genes[index] = @possible_actions.sample if rand < rate
    end
  end

end
