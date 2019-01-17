class V1::OrdersController < V1::ApplicationController
  before_action :set_authenticate, Only: %i[create update]
  before_action :set_order, except: %i[index create]

  def index
    render json: Order.all
  end

  def show
    render json: @order
  end

  def create
    @order = Order.new order_params

    if @order.save
      render json: serialize(@order), status: :created, location: @order
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

  def serialize(order)
    OrderSerializer.new(order).serialized_json
  end

  # Only allow a trusted parameter "white list" through.
  def order_params
    params.permit(:price, :volume, :enabled)
  end
end
