class V1::PhonesController < V1::ApplicationController
  before_action :set_phone, only: [:show, :update, :destroy]

  # GET /phones
  def index
    @phones = Phone.all

    render json: @phones
  end

  # GET /phones/1
  def show
    render json: @phone
  end

  # POST /phones
  def create
    @phone = Phone.new(phone_params)

    if @phone.save
      render json: @phone, status: :created, location: @phone
    else
      render json: @phone.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /phones/1
  def update
    if @phone.update(phone_params)
      render json: @phone
    else
      render json: @phone.errors, status: :unprocessable_entity
    end
  end

  # DELETE /phones/1
  def destroy
    @phone.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phone
      @phone = Phone.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def phone_params
      params.fetch(:phone, {})
    end
end
