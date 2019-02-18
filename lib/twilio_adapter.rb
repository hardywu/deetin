class TwilioAdapter
  attr_reader :client

  def initialize(sid, token)
    @client = Twilio::REST::Client.new(sid, token)
  end

  def send_sms(body:, to:, from: Rails.configuration.twilio_phone_number)
    client.messages.create(
      from: from,
      to: to,
      body: body
    )
  end
end
