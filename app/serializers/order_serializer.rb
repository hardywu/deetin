class OrderSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :price, :volume, :type, :ord_type, :origin_volume, :created_at,
             :state, :trades_count, :funds_received, :base, :quote, :fee
  belongs_to :user
  belongs_to :market
end
