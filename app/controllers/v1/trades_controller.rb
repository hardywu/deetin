class V1::TradesController < V1::ApplicationController
  before_action :set_authenticate
  before_action :set_trade, except: %i[index create]

  def index
    logger.info query_params
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
    if @trade.save
      render json: serialize(@trade), status: :created
    else
      render json: @trade.errors, status: :unprocessable_entity
    end
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

  def market_id
    relationships.fetch(:market, {}).fetch(:data, {}).fetch(:id)
  end
end
