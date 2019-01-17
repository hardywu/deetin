class V1::TransfersController < V1::ApplicationController
  before_action :set_authenticate
  before_action :set_transfer, only: :show
  before_action :set_account, :set_otc, only: :create

  # GET /transfers
  def index
    @transfers = Transfer.all

    render json: @transfers
  end

  # GET /transfers/1
  def show
    render json: @transfer
  end

  # POST /transfers
  def create
    make_transfer
    render json: @transfer, status: :created, location: @transfer
  rescue StandardError
    render json: @transfer.errors, status: :unprocessable_entity
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_transfer
    @transfer = Transfer.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def transfer_params
    params.permit(:currency_id, :amount)
  end

  def set_account
    @account = Account.find_by member_id: current_user.id,
                               currency_id: transfer_params[:currency_id]
  end

  def set_otc
    build_params = {
      member_id: current_user.id,
      currency_id: transfer_params[:currency_id]
    }
    @otc_account = OTCAccount.find_or_create_by build_params
  end

  def make_transfer
    @transfer = Transfer.new(transfer_params)
    amount = transfer_params[:amount]
    Account.transaction do
      Transfer.transaction do
        @account.update! balance: @account.balance - amount
        @otc_account.update! balance: @otc_account.balance + amount
        @transfer.save!
      end
    end
  end
end
