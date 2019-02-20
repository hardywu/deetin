class MarketSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :base_unit, :quote_unit, :code, :name
end
