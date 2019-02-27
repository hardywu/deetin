class V1::Admin::ApplicationController < V1::ApplicationController
  def set_authenticate
    raise Peatio::Auth::Error unless current_user&.role == 'admin'
  end
end
