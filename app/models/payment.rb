# == Schema Information
#
# Table name: payments
#
#  id            :bigint(8)        not null, primary key
#  type          :string(255)
#  name          :string(255)
#  no            :string(255)
#  desc          :text(65535)
#  user_id       :bigint(8)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  limit         :decimal(32, 2)   default(1000.0)
#  daily_limit   :decimal(32, 2)   default(50000.0)
#  monthly_limit :decimal(32, 2)   default(1550000.0)
#  appid         :string(255)
#  pubkey        :text(65535)
#  secret        :text(65535)
#

class Payment < ApplicationRecord
  belongs_to :user
  after_create :set_as_default_for_user
  before_destroy :cannot_delete_the_default_one

  def gen_pay_url
    false
  end

  def default?
    user.payment_id == id
  end

  def set_as_default_for_user
    user.update(payment_id: id, payment_type: type) unless user.payment
  end

  def cannot_delete_the_default_one
    throw(:abort) if default?
  end
end
