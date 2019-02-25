class Order < ApplicationRecord
  belongs_to :market
  belongs_to :user
  enum state: %i[waiting done cancelled passive]

  before_validation :set_attrs

  def fix_number_precision
    fix_price_and_vol
    fix_ori_vol
  end

  def fix_price_and_vol
    self.price = market.fix_number_precision(:base, price.to_d) if price
    self.volume = market.fix_number_precision(:base, volume.to_d) if volume
  end

  def fix_ori_vol
    self.origin_volume = if origin_volume.present?
                           market.fix_number_precision :base, origin_volume.to_d
                         else
                           volume
                         end
  end

  def set_attrs
    self.base = market.base_unit
    self.quote = market.quote_unit
    fix_number_precision
  end
end
