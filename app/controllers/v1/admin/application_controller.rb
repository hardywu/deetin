class V1::Admin::ApplicationController < V1::ApplicationController
  before_action :set_authenticate

  def set_authenticate
    raise Peatio::Auth::Error unless current_user&.role == 'admin'
  end
end
