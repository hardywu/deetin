class V1::Admin::PaymentsController < V1::Admin::ApplicationController
  before_action :set_payment, only: %i[show update destroy]

  # GET /payments
  def index
    @payments = Payment.where(query_params)
                       .order(params[:order_by])
                       .page(params[:page])
                       .per(params[:limit])

    render json: serialize(@payments)
  end

  # GET /payments/1
  def show
    render json: serialize(@payment)
  end

  # POST /payments
  def create
    @payment = Payment.new payment_params

    if @payment.save
      render json: serialize(@payment), status: :created
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /payments/1
  def update
    if @payment.update(payment_params)
      render json: serialize(@payment)
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /payments/1
  def destroy
    @payment.destroy
  end

  private

  def serialize(payment)
    PaymentSerializer.new(payment).serialized_json
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_payment
    @payment = Payment.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def query_params
    params.permit(:user_id, :type)
  end

  # Only allow a trusted parameter "white list" through.
  def payment_params
    attributes.permit(:type, :name, :no, :desc)
  end
end
