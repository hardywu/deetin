# frozen_string_literal: true

require 'net/http'

SMS_URL = 'https://api.smsbao.com/sms'
MESSAGES = {
  '0': '短信发送成功',
  '30': '密码错误',
  '40': '账号不存在',
  '41': '余额不足',
  '43': 'IP地址限制',
  '50': '内容含有敏感词',
  '51': '手机号码不正确'
}

class SmsBao
  cattr_accessor :messages
  self.messages = []

  def initialize(username, password)
    @username = username
    @password = password
  end

  def messages
    self
  end

  def send_sms(*params)
    self.class.messages << OpenStruct.new(params)
    form = {
      u: @username,
      p: Digest::MD5.hexdigest(@password),
      m: params[:to],
      c: params[:body]
    }
    res = Net::HTTP.get_response URI("#{SMS_URL}?#{URI.encode_www_form(form)}")
    result res.body
  end

  def result(code)
    {
      success: (code == '0'),
      code: code,
      message: MESSAGES[code]
    }
  end
end
