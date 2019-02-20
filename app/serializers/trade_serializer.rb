class TradeSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :price, :volume, :market_id
end
