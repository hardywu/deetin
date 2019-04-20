class V1::AccountsController < V1::ApplicationController
  before_action :set_authenticate

  def index
    @accounts = current_user.accounts

    render json: serialize(@accounts)
  end

  def show
    @account = current_user.accounts.find_by currency_id: params[:id]
    render json: serialize(@account)
  end
end
