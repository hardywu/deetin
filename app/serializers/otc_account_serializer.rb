class OtcAccountSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :currency_id, :balance
end
