class V1::QuickTradesController < V1::ApplicationController
  after_action :notify, only: :bid

  def bid
    @trade = Trade.new quick_params.merge(quick_options)
    @trade.generate_no.create_charge_url.quick_record!

    render json: quick_resp(@trade), status: :created
  end

  def done
    @trade = Trade.find_by! no: params[:out_trade_no]
    @trade.done_record!
    @trade.ask_member.add_sale @trade.funds
    Net::HTTP.post URI(@trade.callback_url),
                   quick_req(@trade).to_json,
                   'Content-Type' => 'application/json'
  end

  def demo
    @trade = Trade.new ask_member_id: Bot.find_least_sales_id!,
                       funds: params[:funds],
                       subject: '体验'

    @trade.generate_no.create_charge_url
    render json: quick_resp(@trade), status: :created
  end

  private

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
