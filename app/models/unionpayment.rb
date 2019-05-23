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

class Unionpayment < Payment
  def client
    @client ||= Alipay::Client.new url: Config['ALIPAY_API_URL'].value,
                                   app_id: appid,
                                   app_private_key: secret,
                                   alipay_public_key: pubkey
  end

  def biz_content(funds, ___, trade_no)
    JSON.generate remark: trade_no,
                  money: funds.round(2).to_s,
                  type: 101,
                  paytype: 'CPPAY'
  end

  def gen_pay_url(funds, subj, trade_no)
    redis = Redis.new url: ENV['REDIS_URL']
    redis.subscribe_with_timeout(10, 'qrcode.socket_server') do |on|
      on.subscribe do
        SOCKET_SERVER.send user.device_id, biz_content(funds, subj, trade_no)
      end
      on.message do |_, message|
        event = JSON.parse(message)
        if event['remark'] == trade_no
          @qrcode = event['qrcode']
          logger.debug message + event['remark'] + ' ' + @qrcode
          redis.unsubscribe
        end
      end
    end
    raise StandardError, 'Timeout' if @qrcode.blank?

    @qrcode
  end
end
