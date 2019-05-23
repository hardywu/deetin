class V1::MarketsController < V1::ApplicationController
  before_action :set_market, except: %i[index]

  def index
    @markets = Market.enabled
                     .order(params[:order_by])
                     .page(params[:page])
                     .per(params[:limit])

    render json: serialize(@markets)
  end

  def show
    render json: serialize(@market)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_market
    @market = Market.find params[:id]
  end
end
