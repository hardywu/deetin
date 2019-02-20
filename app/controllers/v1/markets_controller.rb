class V1::MarketsController < V1::ApplicationController
  before_action :set_admin_auth, except: %i[index show]
  before_action :set_market, except: %i[index create]

  def index
    @markets = Market.enabled

    render json: serialize(@markets)
  end

  def show
    render json: serialize(@market)
  end

  def create
    @market = Market.new market_params

    if @market.save
      render json: serialize(@market), status: :created, location: @market
    else
      render json: @market.errors, status: :unprocessable_entity
    end
  end

  def update
    if @market.update(market_params)
      render json: serialize(@market)
    else
      render json: @market.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @market.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_market
    @market = Market.find params[:id]
  end

  def query_param
    params.permit(:uid, :domain, :username)
  end

  def serialize(market)
    MarketSerializer.new(market).serialized_json
  end

  def market_params
    params.fetch(:data, {}).fetch(:attributes, {})
          .permit :base_unit,
                  :quote_unit,
                  :enabled,
                  :base_precision,
                  :quote_precision,
                  :name
  end
end
