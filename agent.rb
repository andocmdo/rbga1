class Agent
  require 'securerandom'

  attr_reader :fitness, :settled_cash, :unsettled_cash, :action_log,
    :last_sale_action_index, :last_buy_action_index, :settle_interval,
    :shares, :total_value, :starting_cash
  attr_accessor :genes

  def initialize(params = {}
    @uuid = SecureRandom.uuid
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
