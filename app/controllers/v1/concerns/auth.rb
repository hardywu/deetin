module V1::Concerns::Auth
  extend ActiveSupport::Concern
  class AuthorizeFailed < StandardError; end

  # JWT authenticator instance. See peatio-core gem.
  #
  # @return [Peatio::Auth::JWTAuthenticator]
  def jwt_authenticator
    @jwt_authenticator ||=
      Peatio::Auth::JWTAuthenticator.new(Rails.configuration.jwt_public_key)
  end

  # Decodes and verifies JWT.
  # Returns authentic member email or raises an exception.
  #
  # @param [Hash] options
  # @return [String, Member, NilClass]
  def authenticate(token)
    if header(token)['alg'] == 'HS256'
      payload, _header = JWT.decode token.split(' ')[1], 'secret'
      payload = payload.symbolize_keys
    else
      payload, _header = jwt_authenticator.authenticate!(token)
    end
    fetch_member(payload)
  rescue StandardError => e
    raise Peatio::Auth::Error, e.inspect
  end

  def header(token)
    str = token.split(' ')[1].split('.')[0]
    str += '=' * (4 - str.length.modulo(4))
    JSON.parse(::Base64.decode64(str.tr('-_', '+/')))
  end

  private

  def fetch_member(payload)
    User.from_payload(payload)
    # Handle race conditions when creating member & authentication records.
    # We do not handle race condition for update operations.
    # http://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
