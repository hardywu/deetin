class Market < ApplicationRecord
  attr_readonly :base_unit, :quote_unit, :base_precision, :quote_precision

  scope :enabled, -> { where(enabled: true) }
  scope :with_base_unit, -> (unit){ where(base_unit: unit) }
  scope :with_quote_unit, -> (unit){ where(quote_unit: unit) }

  validate { errors.add(:base_unit, :invalid) if base_unit == quote_unit }
  validates :id, uniqueness: { case_sensitive: false }, presence: true
  validates :base_unit, :quote_unit, presence: true
  validates :base_precision, :quote_precision, :position, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :base_unit, :quote_unit, inclusion: { in: -> (_) { Currency.codes } }
  validate  :precisions_must_be_same
  validate  :units_must_be_enabled, if: :enabled?

  def as_json(*)
    super.merge!(name: name)
  end

  # alias to_s name

  def latest_price
    Trade.latest_price(self)
  end

  # type is :ask or :bid
  def fix_number_precision(type, d)
    d.round send("#{type}_precision"), BigDecimal::ROUND_DOWN
  end

  def unit_info
    {name: name, base_unit: base_unit, quote_unit: quote_unit}
  end

  private

  def precisions_must_be_same
    if base_precision? && quote_precision? && base_precision != quote_precision
      errors.add(:base_precision, :invalid)
      errors.add(:quote_precision, :invalid)
    end
  end

  def units_must_be_enabled
    %i[quote_unit base_unit].each do |unit|
      errors.add(unit, 'is not enabled.') if Currency.lock.find_by_id(public_send(unit))&.disabled?
    end
  end
end
