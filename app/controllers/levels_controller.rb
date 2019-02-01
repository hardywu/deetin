class LevelsController < ApplicationController
  before_action :set_level, only: [:show, :update, :destroy]

  # GET /levels
  def index
    @levels = Level.all

    render json: @levels
  end

  # GET /levels/1
  def show
    render json: @level
  end

  # POST /levels
  def create
    @level = Level.new(level_params)

    if @level.save
      render json: @level, status: :created, location: @level
    else
      render json: @level.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /levels/1
  def update
    if @level.update(level_params)
      render json: @level
    else
      render json: @level.errors, status: :unprocessable_entity
    end
  end

  # DELETE /levels/1
  def destroy
    @level.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_level
      @level = Level.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def level_params
      params.fetch(:level, {})
    end
end
