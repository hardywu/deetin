class TwilioAdapter
  attr_reader :client

  def initialize(client = Twilio::REST::Client.new)
    @client = client
  end

  def send_sms(body:, to:, from: Rails.configuration.twilio_phone_number)
    client.messages.create(
      from: from,
      to:   to,
      body: body,
    )
  end
end
