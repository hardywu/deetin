class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :email, :uid, :state, :level, :domain
  set_key_transform :camel

  attribute :jwt, if: Proc.new { |record, params|
    params && params[:auth]
  }
end
