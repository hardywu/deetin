class V1::Admin::AccountsController < V1::Admin::ApplicationController
  before_action :set_account, except: %i[index]
  before_action :set_authenticate

  def index
    @accounts = Account.where(query_params)
                       .order(params[:order_by])
                       .page(params[:page])
                       .per(params[:limit])

    render json: serialize(@accounts)
  end

  def show
    render json: serialize(@account)
  end

  private

  def query_params
    params.permit :member_id
  end

  def serialize(account)
    AccountSerializer.new(account).serialized_json
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find params[:id]
  end
end
