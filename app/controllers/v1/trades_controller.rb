class V1::TradesController < V1::ApplicationController
  before_action :set_authenticate
  before_action :set_trade, only: %i[show update await done]

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
    override_opts = { market_id: market_id, state: 'initiated' }.compact
    @trade = Trade.new trade_params.merge(override_opts)

    if @trade.save
      render json: serialize(@trade, params: { jwt: true }), status: :created
    else
      render json: @trade.errors, status: :unprocessable_entity
    end
  end

  def quick_bid
    @trade = Trade.new quick_params
    check_master :bid_member
    @trade.ask_member = current_user.rich_bot
    @trade.quick_record!
    render json: serialize(@trade), status: :created
  end

  def quick_ask
    @trade = Trade.new quick_params
    check_master :ask_member
    @trade.bid_member = current_user.poor_bot
    @trade.quick_record!
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
    attrs = %i[state ask_member_id market_id bid_member_id ask_id bid_id price]
    params.permit(attrs, state: []).reverse_merge(state: 'waiting')
  end

  def set_trade
    @trade = Trade.find params[:id]
  end

  def serialize(*args)
    TradeSerializer.new(*args).serialized_json
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

  def check_master(member)
    raise InvalidParamError, "#{member} master not corret" unless
      @trade.public_send(member)&.master == current_user
  end

  def market_id
    relationships.fetch(:market, {}).fetch(:data, {}).fetch(:id)
  end
end
