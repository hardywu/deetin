class UserSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :email, :uid, :state, :level, :domain, :role, :username,
             :otp, :referral_id, :created_at
  has_one :profile
  has_many :payments
end
