class TradeSerializer
  include FastJsonapi::ObjectSerializer
  attributes :price, :volume, :market_id
end
