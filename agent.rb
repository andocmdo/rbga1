class Agent
  attr_reader :fitness, :settled_cash, :unsettled_cash, :action_log,
    :last_sale_action_index, :last_buy_action_index, :settle_interval,
    :shares, :total_value, :starting_cash
  attr_accessor :genes

  def initialize(params = {})
    @genes = []
    @fitness = 0.0
    @starting_cash = params.fetch("starting_cash", 10000.00)
    @settled_cash = @starting_cash
    @unsettled_cash = params.fetch("unsettled_cash", 0.0)
    @possible_actions = ["b", "s", "h"]
    @action_log = []
    @last_sale_action_index = 999999999
    @last_buy_action_index = 999999999
    @trade_cost = params.fetch("trade_cost", 4.95)
    @settle_interval = params.fetch("settle_interval", 2)
    @shares = 0
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

      # JANK?
      if @genes[index] == "b"
        # bookeeping first
        purchase_price = record["4. close"].to_f # JANK
        if @settled_cash > (purchase_price + @trade_cost) # we have enough to buy at least 1 share
          shares_to_buy = ((@settled_cash - @trade_cost) / purchase_price).to_i
          transaction_cost = shares_to_buy * purchase_price + @trade_cost
          @settled_cash -= transaction_cost
          @shares = shares_to_buy
          @last_buy_action_index = index
          add_action_to_log("buy", record, index)
        else
          add_action_to_log("unsuccessful_buy", record, index)
        end
      elsif @genes[index] == "s"
        if @shares >= 1
          sale_price = record["4. close"].to_f # JANK
          transaction_profit = @shares * sale_price
          @unsettled_cash += transaction_profit - @trade_cost
          @shares = 0
          @last_sale_action_index = index
          add_action_to_log("sell", record, index)
        else
          add_action_to_log("unsuccessful_sell", record, index)
        end
      else
        # do nothing
        add_action_to_log("hold", record, index)
      end
      # update the total_current_value
      @total_value = total_current_value(record)
    end
    @fitness = @total_value / @starting_cash
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

  private
  def add_action_to_log(action, record, index)
    @action_log << { id: index, action: action, total_value: total_current_value(record).to_f,
      settled_cash: @settled_cash.to_f, unsettled_cash: @unsettled_cash.to_f, shares: @shares }   # need to fill in more info here
  end

  # need to make a way to get value without a record...
  def total_current_value(record)
    sale_price = record["4. close"].to_f # JANK
    return @settled_cash + @unsettled_cash + (@shares * sale_price)
  end

end
