class V1::TradesController < V1::ApplicationController
  before_action :set_authenticate, except: %i[show]
  before_action :set_trade, only: %i[show done]

  def index
    trades = Trade.where(query_params)
                  .order(params[:order_by])
                  .page(params[:page])
                  .per(params[:limit])

    render json: serialize(trades)
  end

  def show
    set_authenticate
    to_includes = %i[market ask bid ask_member bid_member]
    render json: serialize(@trade, include: to_includes)
  rescue Peatio::Auth::Error
    render json: serialize(@trade, include: %i[market ask bid ask_member])
  end

  def create
    @trade = Trade.new trade_params.merge(state: 'waiting')

    if @trade.save
      render json: serialize(@trade), status: :created
    else
      render json: @trade.errors, status: :unprocessable_entity
    end
  end

  def done
    @trade.state == 'done' || @trade.done_record!
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
end
