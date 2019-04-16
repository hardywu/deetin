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

class Alipayment < Payment
  before_create :generate_rsa
  def client
    @client ||= Alipay::Client.new url: Config['ALIPAY_API_URL'].value,
                                   app_id: appid,
                                   app_private_key: secret,
                                   alipay_public_key: pubkey
  end

  def generate_rsa
    rsa_key = OpenSSL::PKey::RSA.new(2048)
    assign_attributes pubkey: rsa_key.public_key.to_pem, secret: rsa_key.to_pem
  end
end
