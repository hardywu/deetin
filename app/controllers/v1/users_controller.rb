class V1::UsersController < V1::ApplicationController
  before_action :set_user, only: %i[show update destroy]
  before_action :set_query, only: %i[index]
  before_action :set_authenticate
  before_action :preset_user, only: :bind_device

  # GET /users
  def index
    render json: serialize(@users, include: [:payments])
  end

  # GET /users/1
  def show
    render json: serialize(@user, include: [:payments])
  end

  # POST /users
  def create
    @user = klass.new user_params.reverse_merge(default_params)
    authorize @user

    if @user.save
      render json: serialize(@user, params: { jwt: true }), status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: serialize(@user)
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy!
  end

  def devices_table
    render json: SOCKET_SERVER.devices_table
  end

  def devices_unlogged
    render json: SOCKET_SERVER.devices_without_app_id
  end

  def bind_device
    if @user.update(device_id: @device_id)
      SOCKET_SERVER.login(@user.device_id, @user.id)
      render json: { message: 'submit connection request' }
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def set_query
    @users = current_user.subs
                         .where(query_params)
                         .order(params[:order_by])
                         .page(params[:page])
                         .per(params[:limit])
  end

  def preset_user
    set_user
    unless @user.payment_type == 'Unionpayment'
      raise InvalidParamError, 'Incorrect default payment'
    end
    raise InvalidParamError, 'device already associated' if
      @user.device_id.present?

    @device_id = SOCKET_SERVER.devices_without_app_id[0]
    raise InvalidParamError, 'no pending device' if @device_id.blank?
  end

  def klass
    params.fetch(:data, {}).fetch(:type, 'member') == 'bot' ? Bot : Member
  end

  def query_params
    params.permit(:email, :username, :uid, :type)
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    attributes.permit %i[email username enabled payment_id payment_type]
  end

  def default_params
    { state: 'active', domain: current_user.uid }
  end
end
