class V1::PositionsController < V1::ApplicationController
  before_action :set_authenticate
  # before_action :set_trade, except: %i[index create]

  def index
    pos = current_user&.role == 'admin' ? Position.all : current_user.positions

    render json: serialize(pos)
  end

  private

  def set_position
    @position = Position.find params[:id]
  end

  def serialize(position)
    PositionSerializer.new(position).serialized_json
  end
end
