# == Schema Information
#
# Table name: markets
#
#  id              :bigint(8)        not null, primary key
#  base_unit       :string(10)       not null
#  quote_unit      :string(10)       not null
#  base_precision  :integer          default(8), not null
#  quote_precision :integer          default(8), not null
#  enabled         :boolean          default(TRUE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  type            :string(255)
#  code            :string(255)
#  name            :string(255)
#

class OtcMarket < Market
  validates :base_precision, :quote_precision, :position, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :base_unit, :quote_unit, inclusion: { in: -> (_) { Currency.codes } }
  validate  :units_must_be_enabled, if: :enabled?

  validate { errors.add(:base_unit, :invalid) if base_unit == quote_unit }
  validates :id, uniqueness: { case_sensitive: false }, presence: true
  validates :base_unit, :quote_unit, presence: true
  validate  :precisions_must_be_same
end
