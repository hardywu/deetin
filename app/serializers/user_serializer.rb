class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :email, :uid, :state, :level
end
