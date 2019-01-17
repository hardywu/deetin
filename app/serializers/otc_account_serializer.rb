class OtcAccountSerializer
  include FastJsonapi::ObjectSerializer
  attributes :currency_id, :balance
end
