class TradeSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :price, :volume, :market_id, :state, :funds,
             :base_unit, :quote_unit, :ask_alipay, :bid_alipay
  belongs_to :market
  belongs_to :ask, record_type: :order, serializer: OrderSerializer
  belongs_to :bid, record_type: :order, serializer: OrderSerializer
  belongs_to :ask_member, record_type: :user, serializer: UserSerializer
  belongs_to :bid_member, record_type: :user, serializer: UserSerializer
end
