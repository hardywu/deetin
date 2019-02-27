class V1::AccountsController < V1::ApplicationController
  before_action :set_authenticate

  def index
    @accounts = klass_col.where(query_params)
                         .order(params[:order_by])
                         .page(params[:page])
                         .per(params[:limit])

    render json: serialize(@accounts)
  end

  def show
    @account = current_user.accounts.find params[:id]
    render json: serialize(@account)
  end

  private

  def klass_col
    current_user&.role == 'admin' ? Account.all : current_user.accounts
  end

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
