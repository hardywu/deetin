module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      payload, _header = JWT.decode request.params[:token]
      User.find!(payload['id'])
    rescue StandardError
      reject_unauthorized_connection
    end
  end
end
