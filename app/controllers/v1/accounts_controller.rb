class V1::AccountsController < V1::ApplicationController
  before_action :set_account, except: %i[index]
  before_action :set_authenticate

  def index
    @accounts = current_user.accounts

    render json: serialize(@accounts)
  end

  def show
    render json: serialize(@account)
  end

  private

  def serialize(account)
    AccountSerializer.new(account).serialized_json
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find params[:id]
  end
end
