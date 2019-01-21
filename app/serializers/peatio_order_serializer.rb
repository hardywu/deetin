class PeatioOrderSerializer
  include FastJsonapi::ObjectSerializer
  attributes :price, :volume, :type, :ord_type, :avg_price,
             :state, :market_id, :created_at, :origin_volume,
             :executed_volume, :trades_count

  attribute :side do |object|
    object.type[-3, 3] == 'Ask' ? 'sell' : 'buy'
  end
end
