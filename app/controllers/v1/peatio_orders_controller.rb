class V1::PeatioOrdersController < V1::ApplicationController
  before_action :set_authenticate

  def index
    orders = PeatioOrder.where(order_params)
                        .order(params[:order_by])
                        .page(params[:page])
                        .per(params[:limit])

    render json: orders
  end

  # Only allow a trusted parameter "white list" through.
  def order_params
    defaults = {
      state: 'wait',
      member_id: current_user.id
    }
    params.permit(:state).reverse_merge(defaults)
  end

  def query_params
    defaults = {
      limit: 100,
      page: 1,
      order_by: 'asc'
    }
    params.permit(:limit, :page, :order_by).reverse_merge(defaults)
  end
end
