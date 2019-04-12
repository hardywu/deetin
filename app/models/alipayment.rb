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
#  pubkey        :string(255)
#  secret        :string(255)
#

ALIPAY_API_URL = 'https://openapi.alipaydev.com/gateway.do'.freeze

class Alipayment < Payment
  def client
    @client ||= Alipay::Client.new url: ALIPAY_API_URL,
                                   app_id: appid,
                                   app_private_key: secret,
                                   alipay_public_key: pubkey
  end
end
