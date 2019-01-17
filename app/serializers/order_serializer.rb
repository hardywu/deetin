class OrderSerializer
  include FastJsonapi::ObjectSerializer
  attributes :price, :volume, :type, :ord_type
end
