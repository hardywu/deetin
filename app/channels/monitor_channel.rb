class MonitorChannel < ApplicationCable::Channel
  def subscribed
    reject_unauthorized_connection unless current_user.role == 'admin'
    stream_from 'monitor:'
  end
end
