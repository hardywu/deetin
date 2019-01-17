class V1::ApplicationController < ActionController::API
  include Concerns::Auth
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from AuthorizeFailed, with: :not_authorized
  rescue_from NoMethodError, with: :internal_error
  rescue_from Peatio::Auth::Error, with: :not_authenticated

  private

  def record_not_found(err)
    render json: { errors: [{ msg: err.message }] }, status: :not_found
  end

  def not_authorized(err)
    render json: { errors: [{ msg: err.message }] }, status: :forbidden
  end

  def not_authenticated(err)
    render json: { errors: [{ msg: err.message }] },
           status: :unauthorized
  end

  def root
    render json: {}
  end

  def set_authenticate
    raise Peatio::Auth::Error unless current_user
  end

  def current_user
    @current_user ||= authenticate(request.headers['Authorization'])
  end
end
