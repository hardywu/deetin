class SmsClient
  def initialize(adapter)
    @adapter = adapter
  end

  def send_sms(body:, to:, from: Rails.configuration.twilio_phone_number)
    @adapter.send_sms(body, to, from)
  end
end
