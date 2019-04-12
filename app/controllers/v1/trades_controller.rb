class V1::TradesController < V1::ApplicationController
  before_action :set_authenticate, except: %i[show quick_bid quick_done]
  before_action :set_trade, only: %i[show done]
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
    @trade = Trade.new trade_params.merge(state: 'waiting')

    if @trade.save
      render json: serialize(@trade), status: :created
    else
      render json: @trade.errors, status: :unprocessable_entity
    end
  end

  def quick_bid
    @trade = Trade.new quick_params.merge(quick_options)
    @trade.generate_no.create_charge_url.quick_record!

    render json: quick_resp(@trade), status: :created
  end

  def quick_done
    @trade = Trade.find_by! no: params[:out_trade_no]
    @trade.done_record!
    Net::HTTP.post URI(@trade.callback_url),
                   quick_req(@trade).to_json,
                   'Content-Type' => 'application/json'
    render json: @trade
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
    master.verify_sign!(params_str_to_sign, params[:sign])
    master.members.find_or_create_by! email: params[:email]
  end

  def master
    @master ||= User.find_by!(uid: params[:uid])
  end

  def quick_params
    params.permit(%i[funds callbackUrl subject]).transform_keys!(&:underscore)
  end

  def params_str_to_sign
    params.permit(%i[subject funds callbackUrl uid email]).to_query
  end

  def quick_options
    {
      state: 'waiting', price: QUICK_PRICE, market_id: QUICK_MARKET,
      bid_member: bidder, ask_member_id: Bot.find_least_sales_id!,
      volume: params[:funds].to_f / QUICK_PRICE, master: master
    }
  end

  def quick_resp(trade)
    trade.slice(%i[charge_url no state funds]).transform_keys! do |key|
      key.camelize :lower
    end
  end

  def quick_req(trade)
    req = trade.slice(%i[funds no state])
    req['sign'] = trade.master.encript_sign req.to_query
    req
  end

  def notify
    MonitorChannel.broadcast_to nil, serialize(@trade)
    NotificationChannel.broadcast_to @trade.ask_member, serialize(@trade)
  end
end
