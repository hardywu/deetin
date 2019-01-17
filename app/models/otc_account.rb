class OtcAccount < ApplicationRecord
  belongs_to :member
  validates :member_id, uniqueness: { scope: :currency_id }
  validates :balance, numericality: { greater_than_or_equal_to: 0.to_d }
end
