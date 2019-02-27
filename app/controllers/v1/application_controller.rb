class V1::ApplicationController < ActionController::API
  include V1::Concerns::Auth
  include V1::Concerns::Constants
  rescue_from StandardError, with: :invalid_param
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from AuthorizeFailed, with: :not_authorized
  rescue_from NoMethodError, with: :internal_error
  rescue_from Peatio::Auth::Error, with: :not_authenticated
  rescue_from InvalidParamError, with: :invalid_param
  rescue_from ActionController::ParameterMissing, with: :invalid_param
  rescue_from ActiveRecord::NotNullViolation, with: :invalid_param
  rescue_from ActiveRecord::ActiveRecordError, with: :invalid_param

  private

  def record_not_found(err)
    render json: serialize_error(err, NOT_FOUND), status: :not_found
  end

  def not_authorized(err)
    render json: serialize_error(err, NOT_ALLOWED), status: :forbidden
  end

  def not_authenticated(err)
    render json: serialize_error(err, LOGIN_FAILED),
           status: :unauthorized
  end

  def internal_error(err)
    render json: serialize_error(err, INTERNAL_ERROR),
           status: :internal_server_error
  end

  def invalid_param(err)
    render json: serialize_error(err, PARAMS_INVALID),
           status: :unprocessable_entity
  end

  def serialize_error(err, code)
    {
      errors: [
        code: code,
        detail: err.message
      ]
    }
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

  def attributes
    params.fetch(:data, {}).fetch(:attributes, {})
  end

  def relationships
    params.fetch(:data, {}).fetch(:relationships, {})
  end
end
