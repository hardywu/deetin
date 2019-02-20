class PaymentSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :name, :no, :desc, :type
  has_one :user
end
