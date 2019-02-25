class V1::OrdersController < V1::ApplicationController
  before_action :set_authenticate, only: %i[create update]
  before_action :set_order, except: %i[index create]

  def index
    orders = Order.where(query_params)
                  .order(params[:order_by])
                  .page(params[:page])
                  .per(params[:limit])

    render json: serialize(orders, { include: %i[user] })
  end

  def show
    render json: serialize(@order, { include: %i[user user.payments] })
  end

  def create
    @order = klass.new order_params.merge(market_id: market_id)
    @order.user = current_user

    if @order.save
      render json: serialize(@order), status: :created
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      render json: serialize(@order)
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find params[:id]
  end

  def serialize(*args)
    OrderSerializer.new(*args).serialized_json
  end

  def klass
    case params.fetch(:data, {}).fetch(:type)
    when 'bid'
      Bid
    when 'ask'
      Ask
    else
      raise ActiveRecord::RecordNotFound, 'No Order Type found'
    end
  end

  # Only allow a trusted parameter "white list" through.
  def order_params
    params.fetch(:data, {}).fetch(:attributes, {})
          .permit(:price, :volume, :ord_type, :state)
  end

  # Only allow a trusted parameter "white list" through.
  def query_params
    defaults = {
      state: 'waiting'
    }.compact
    params.permit(:state, :user_id, :market_id).reverse_merge(defaults)
  end

  def market_id
    params.fetch(:data, {}).fetch(:relationships, {})
          .fetch(:market, {}).fetch(:data, {}).fetch(:id)
  end
end
