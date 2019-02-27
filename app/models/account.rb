# == Schema Information
#
# Table name: accounts
#
#  id          :bigint(8)        not null, primary key
#  member_id   :integer          not null
#  currency_id :string(10)       not null
#  balance     :decimal(32, 16)  default(0.0), not null
#  locked      :decimal(32, 16)  default(0.0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Account < ApplicationRecord
  ZERO = 0.to_d
  class AccountError < StandardError; end
  include BelongsToCurrency

  belongs_to :member, class_name: 'User', required: true
  validates :member_id, uniqueness: { scope: :currency_id }
  validates :balance, :locked, numericality: { greater_than_or_equal_to: ZERO }
  scope :enabled, -> { joins(:currency).merge(Currency.where(enabled: true)) }

  # Returns active deposit address for account or creates new if any exists.
  def payment_address
    return unless currency.coin?

    payment_addresses.last&.enqueue_address_generation ||
      payment_addresses.create!(currency: currency)
  end

  # Attempts to create additional deposit address for account.
  def payment_address!
    return unless currency.coin?

    record = payment_address

    # The address generation process is in progress.
    if record.address.blank?
      record
    else
      # allows user to have multiple addresses.
      payment_addresses.create!(currency: currency)
    end
  end

  def plus_funds!(amount)
    update_columns((attributes_after_plus_funds!(amount)))
  end

  def plus_funds(amount)
    with_lock { plus_funds!(amount) }
    self
  end

  def attributes_after_plus_funds!(amount)
    raise AccountError, "Cannot add funds (amount: #{amount})." if
      amount <= ZERO

    { balance: balance + amount }
  end

  def sub_funds!(amount)
    update_columns(attributes_after_sub_funds!(amount))
  end

  def sub_funds(amount)
    with_lock { sub_funds!(amount) }
    self
  end

  def attributes_after_sub_funds!(amount)
    amounted = amount <= ZERO || amount > balance
    raise AccountError, "Cannot subtract funds (amount: #{amount})." if amounted

    { balance: balance - amount }
  end

  def lock_funds!(amount)
    update_columns(attributes_after_lock_funds!(amount))
  end

  def lock_funds(amount)
    with_lock { lock_funds!(amount) }
    self
  end

  def attributes_after_lock_funds!(amount)
    amounted = amount <= ZERO || amount > balance
    raise AccountError, "Cannot lock funds (amount: #{amount})." if amounted

    { balance: balance - amount, locked: locked + amount }
  end

  def unlock_funds!(amount)
    update_columns(attributes_after_unlock_funds!(amount))
  end

  def unlock_funds(amount)
    with_lock { unlock_funds!(amount) }
    self
  end

  def attributes_after_unlock_funds!(amount)
    amounted = amount <= ZERO || amount > locked
    raise AccountError, "Cannot unlock funds (amount: #{amount})." if amounted

    { balance: balance + amount, locked: locked - amount }
  end

  def unlock_and_sub_funds!(amount)
    update_columns(attributes_after_unlock_and_sub_funds!(amount))
  end

  def unlock_and_sub_funds(amount)
    with_lock { unlock_and_sub_funds!(amount) }
    self
  end

  def attributes_after_unlock_and_sub_funds!(amount)
    amounted = amount <= ZERO || amount > locked
    raise AccountError, "Cannot unlock funds (amount: #{amount})." if amounted

    { locked: locked - amount }
  end

  def amount
    balance + locked
  end

  # def as_json(*)
  #   super.merge! \
  #     deposit_address: payment_address&.address,
  #     currency:        currency_id
  # end
end
