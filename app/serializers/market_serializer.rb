class MarketSerializer
  include FastJsonapi::ObjectSerializer
  attributes :base_unit, :quote_unit
end
