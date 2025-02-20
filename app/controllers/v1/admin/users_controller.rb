class V1::Admin::UsersController < V1::Admin::ApplicationController
  before_action :set_user, only: %i[show update destroy]

  # GET /users
  def index
    @users = User.where(query_params)
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
    @user = User.new user_params.reverse_merge(state: 'active')

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

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def query_params
    params.permit(:email, :domain, :username, :uid, :type, :state)
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    attributes.permit(:email, :username, :role, :state)
  end
end
