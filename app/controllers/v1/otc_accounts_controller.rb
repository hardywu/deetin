class V1::OtcAccountsController < V1::ApplicationController
  before_action :set_authenticate
  before_action :set_account

  def index
    @otc_accounts = current_user.otc_accounts
    render json: serialize(@otc_accounts)
  end

  def show
    @otc_account = current_user.otc_accounts.find params[:id]
    render json: serialize(@otc_account)
  end

  private

  def serialize(account)
    OtcAccountSerializer.new(account).serialized_json
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @otc_account = OtcAccount.find params[:id]
  end
end
