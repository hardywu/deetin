# == Schema Information
#
# Table name: orders
#
#  id             :bigint(8)        not null, primary key
#  type           :string(8)        not null
#  base           :string(10)       not null
#  quote          :string(10)       not null
#  market_id      :string(20)       not null
#  price          :decimal(32, 16)
#  volume         :decimal(32, 16)  not null
#  origin_volume  :decimal(32, 16)  not null
#  fee            :decimal(32, 16)  default(0.0), not null
#  state          :integer          default("waiting"), not null
#  user_id        :integer          not null
#  funds_received :decimal(32, 16)  default(0.0)
#  trades_count   :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  ord_type       :string(255)      default("limit"), not null
#

class Order < ApplicationRecord
  belongs_to :market, required: true
  belongs_to :user, required: true
  enum state: %i[waiting done cancelled passive]
  ZERO = 0.to_d
  before_validation :set_attrs
  before_update { |order| order.state = 'done' if order.volume == ZERO }
  validates :price, :volume, numericality: { greater_than_or_equal_to: 0.to_d }

  delegate :lock_funds!, to: :hold_account!
  delegate :plus_funds!, to: :hold_account!
  delegate :sub_funds!, to: :hold_account!

  # @deprecated
  def hold_account
    (user.master || user).get_account(base)
  end

  # @deprecated
  def hold_account!
    Account.lock.find_or_create_by! member_id: user.master&.id || user_id,
                                    currency_id: base
  end

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
    self.base = Market.id_to_base(market_id)
    self.quote = Market.id_to_quote(market_id)
    fix_number_precision
  end
end
