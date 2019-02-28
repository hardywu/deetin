class V1::UsersController < V1::ApplicationController
  before_action :set_user, only: %i[show update destroy]
  before_action :set_query, only: %i[index]
  before_action :set_authenticate

  # GET /users
  def index
    render json: serialize(@users, params: { jwt: true })
  end

  # GET /users/1
  def show
    render json: serialize(@user)
  end

  # POST /users
  def create
    @user = klass.new user_params.reverse_merge(default_params)

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

  private

  def serialize(*args)
    UserSerializer.new(*args).serialized_json
  end

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

  def klass
    params.fetch(:data, {}).fetch(:type, 'member') == 'bot' ? Bot : Member
  end

  def query_params
    params.permit(:email, :username, :uid, :type)
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    attributes.permit(:email, :username)
  end

  def default_params
    { state: 'active', master_id: current_user.id }
  end
end
