# == Schema Information
#
# Table name: users
#
#  id              :bigint(8)        not null, primary key
#  uid             :string(255)      not null
#  domain          :string(255)
#  email           :string(255)      not null
#  password_digest :string(255)      not null
#  role            :string(255)      default("member"), not null
#  level           :integer          default(0), not null
#  state           :string(255)      default("pending"), not null
#  otp             :boolean          default(FALSE)
#  referral_id     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  username        :string(255)
#  type            :string(255)
#  enabled         :boolean          default(FALSE), not null
#  secret          :string(255)
#

class Bot < User
  belongs_to :master, class_name: 'User',
                      primary_key: 'uid',
                      foreign_key: :domain
  before_validation :set_attrs
  delegate :client, to: :alipay, prefix: true

  def sales
    Rails.cache.fetch("bot_sales/#{id}", expires_in: 24.hours) { 0 }
  end

  def set_attrs
    self.password = '000000'
  end

  def authenticate(_unencrypted_password)
    false
  end

  def add_sale(sale)
    Rails.cache.write("bot_sales/#{id}", sales + sale)
  end

  def self.find_least_sales
    keys = Bot.enabled.ids.map { |x| "bot_sales/#{x}" }
    all_sales = Rails.cache.fetch_multi(*keys) { 0 }
    min_sales = all_sales.min_by { |_, v| v }
    return unless min_sales

    find min_sales[0].split('/')[1]
  end
end
