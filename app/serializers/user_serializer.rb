class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :email, :uid
end
