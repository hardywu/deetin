class V1::TradesController < V1::ApplicationController
  before_action :set_authenticate, except: %i[show quick_bid quick_done]
  before_action :set_trade, only: %i[show update done]
  after_action :notify, only: :quick_bid

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
    override_opts = { market_id: market_id, state: 'waiting' }.compact
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

  def quick_bid
    @trade = Trade.new quick_params
    @trade.quick_record!
    @trade.charge_url = @trade.create_charge_url

    render json: @trade, status: :created
  end

  def quick_done
    @trade = Trade.find_by! no: params[:out_trade_no]
    @trade.done_record!
    Net::HTTP.post URI(@trade.callbackUrl),
                   TradeSerializer.new(@trade).serialized_json,
                   'Content-Type' => 'application/json'
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

  def bidder
    @master = User.find_by(uid: params[:uid])
    @master.verify_sign!(sign_params_str, params[:sign])
    @master.members.find_or_create_by domain: params[:uid],
                                      email: params[:email]
  end

  def quick_params
    params.permit(%i[funds callbackUrl no])
          .transform_keys!(&:underscore)
          .merge(quick_options)
  end

  def sign_params_str
    params.permit(%i[funds callbackUrl no uid]).to_s
  end

  def quick_options
    {
      state: 'waiting', price: QUICK_PRICE, market_id: QUICK_MARKET,
      bid_member: bidder, ask_member: Bot.find_least_sales
    }
  end

  def notify
    MonitorChannel.broadcast_to nil, serialize(@trade)
    NotificationChannel.broadcast_to @trade.ask_member, serialize(@trade)
  end

  def market_id
    relationships.fetch(:market, {}).fetch(:data, {}).fetch(:id)
  end
end
