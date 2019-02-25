class V1::UsersController < V1::ApplicationController
  before_action :set_user, only: %i[show update destroy]
  before_action :set_authenticate

  # GET /users
  def index
    @users = klass_col.where(query_params)
                      .order(params[:order_by])
                      .page(params[:page])
                      .per(params[:limit])

    render json: serialize(@users, params: { jwt: true })
  end

  # GET /users/1
  def show
    render json: serialize(@user)
  end

  # POST /users
  def create
    @user = klass_col.new user_params.merge(state: 'active')

    if @user.save
      render json: serialize(@user), status: :created
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
    @user.destroy
  end

  private

  def serialize(*args)
    UserSerializer.new(*args).serialized_json
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def klass_col
    current_user&.role == 'admin' ? User.all : current_user.members
  end

  def query_params
    params.permit(:email, :master_id, :username, :uid)
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.fetch(:data, {}).fetch(:attributes, {})
          .permit(:email, :username)
  end
end
