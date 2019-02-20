class V1::ProfilesController < V1::ApplicationController
  before_action :check_admin
  before_action :set_profile, only: %i[show update destroy]

  # GET /profiles
  def index
    @profiles = Profile.all

    render json: @profiles
  end

  # GET /profiles/1
  def show
    render json: @profile
  end

  # POST /profiles
  def create
    @profile = Profile.new(profile_params)

    if @profile.save
      render json: @profile, status: :created
    else
      render json: @profile.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /profiles/1
  def update
    if @profile.update(profile_params)
      render json: @profile
    else
      render json: @profile.errors, status: :unprocessable_entity
    end
  end

  # DELETE /profiles/1
  def destroy
    @profile.destroy
  end

  private

  def check_admin
    set_admin_auth unless params[:id] == 'me'
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    @profile = if params[:id] == 'me'
                 current_user.profile
               else
                 Profile.find(params[:id])
               end
  end

  # Only allow a trusted parameter "white list" through.
  def profile_params
    params.fetch(:profile, {})
  end
end
