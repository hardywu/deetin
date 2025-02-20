# == Schema Information
#
# Table name: markets
#
#  base_precision  :integer          default(8), not null
#  quote_precision :integer          default(8), not null
#  enabled         :boolean          default(TRUE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  type            :string(255)
#  name            :string(255)
#  id              :string(20)       not null, primary key
#  position        :integer          default(0), not null
#

class Market < ApplicationRecord
  scope :enabled, -> { where(enabled: true) }
  scope :with_base_unit, ->(unit) { where('column ~* ?', "^#{unit}\/") }
  scope :with_quote_unit, ->(unit) { where('column ~* ?', "\/#{unit}$") }

  def quote_unit
    id.split('/')[1]
  end

  def base_unit
    id.split('/')[0]
  end

  def as_json(*)
    super.merge!(name: name)
  end

  # alias to_s name

  def latest_price
    Trade.latest_price(self)
  end

  # type is :ask or :bid
  def fix_number_precision(type, digit)
    digit.round send("#{type}_precision"), BigDecimal::ROUND_DOWN
  end

  def unit_info
    { name: name, base_unit: base_unit, quote_unit: quote_unit }
  end

  def self.id_to_quote(id)
    id.split('/')[1]
  end

  def self.id_to_base(id)
    id.split('/')[0]
  end

  private

  def precisions_must_be_same
    return unless base_precision? && quote_precision? &&
                  base_precision != quote_precision

    errors.add(:base_precision, :invalid)
    errors.add(:quote_precision, :invalid)
  end

  def units_must_be_enabled
    %i[quote_unit base_unit].each do |unit|
      next unless Currency.lock.find_by(id: public_send(unit))&.disabled?

      errors.add(unit, 'is not enabled.')
    end
  end
end
