class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :email, :uid, :state, :level, :domain
  set_key_transform :camel
end
