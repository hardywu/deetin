class V1::TradesController < V1::ApplicationController
  before_action :set_authenticate
  before_action :set_trade, except: %i[index create]

  def index
    @trades = current_user.trades
    render json: serialize(@trades)
  end

  def show
    render json: @trade
  end

  def create
    @trade = Trade.new trade_params
  end

  def update
    @trade.update trade_params
  end

  private

  def set_trade
    @trade = Trade.find params[:id]
  end

  def serialize(trade)
    TradeSerializer.new(trade).serialized_json
  end

  # Only allow a trusted parameter "white list" through.
  def trade_params
    params.permit(:price, :volume, :enabled)
  end
end
