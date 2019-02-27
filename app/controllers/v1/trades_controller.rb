class V1::TradesController < V1::ApplicationController
  before_action :set_authenticate
  before_action :set_trade, except: %i[index create]

  def index
    trades = Trade.where(query_params)
                  .order(params[:order_by])
                  .page(params[:page])
                  .per(params[:limit])

    render json: serialize(trades)
  end

  def show
    to_includes = %i[market ask bid ask_member bid_member]
    render json: serialize(@trade, include: to_includes)
  end

  def create
    @trade = Trade.new trade_params.merge(override_opts)

    render json: serialize(@trade), status: :created
  end

  def quick
    @trade = Trade.new quick_params
    check_members
    quick_record
    render json: serialize(@trade), status: :created
  end

  def update
    if @trade.update(trade_params)
      render json: serialize(@trade)
    else
      render json: @trade.errors, status: :unprocessable_entity
    end
  end

  def await
    if @trade.update(state: 'waiting')
      MonitorChannel.broadcast_to nil, serialize(@trade)
      NotificationChannel.broadcast_to @trade.ask_member, serialize(@trade)
      render json: serialize(@trade)
    else
      render json: @trade.errors, status: :unprocessable_entity
    end
  end

  def done
    ActiveRecord::Base.transaction do
      @trade.update! state: 'done'
      @trade.ask.unlock_and_sub_funds!(@trade.volume)
      @trade.bid.plus_funds!(@trade.volume)
      @trade.ask.update! state: 'done'
      @trade.bid.update! state: 'done'
    end
    render json: serialize(@trade)
  end

  private

  def query_params
    defaults = { state: 'waiting' }.compact
    attrs = %i[state ask_member_id market_id bid_member_id ask_id bid_id price]
    params.permit(attrs, state: []).reverse_merge(defaults)
  end

  def set_trade
    @trade = Trade.find params[:id]
  end

  def serialize(*args)
    TradeSerializer.new(*args).serialized_json
  end

  def override_opts
    {
      market_id: market_id,
      state: 'initiated'
    }.compact
  end

  # Only allow a trusted parameter "white list" through.
  def trade_params
    attributes.permit :price, :volume, :enabled, :market_id,
                      :funds, :ask_id, :bid_id
  end

  def quick_params
    state = attributes[:state] == 'done' ? 'done' : 'waiting'
    attributes.permit(:price, :volume, :market_id, :funds,
                      :ask_member_id, :bid_member_id).merge(state: state)
  end

  def check_members
    cond = (!@trade.ask_member == !@trade.bid_member)
    @trade.ask_member ||= current_user.rich_bot
    @trade.bid_member ||= current_user.poor_bot
    cond ||= @trade.ask_member&.master != current_user
    cond ||= @trade.bid_member&.master != current_user
    raise InvalidParamError if cond
  end

  def quick_record
    ActiveRecord::Base.transaction do
      order_params = @trade.slice(%i[price volume market_id state])
      @trade.ask = Ask.create! user: @trade.ask_member, **order_params
      @trade.bid = Bid.create! user: @trade.bid_member, **order_params
      @trade.save!
      if @trade.state == 'done'
        @trade.ask.sub_funds!(@trade.volume)
        @trade.bid.plus_funds!(@trade.volume)
      else
        @trade.ask.lock_funds!(@trade.volume)
      end
    end
  end

  def market_id
    relationships.fetch(:market, {}).fetch(:data, {}).fetch(:id)
  end
end
