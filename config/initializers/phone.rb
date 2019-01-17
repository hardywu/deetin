require_dependency 'twilio_adapter'

sid = ENV.fetch('TWILIO_ACCOUNT_SID', '')
token = ENV.fetch('TWILIO_AUTH_TOKEN', '')
Rails.configuration.twilio_phone_number = ENV.fetch('TWILIO_PHONE_NUMBER', '')
SMSClient = TwilioAdapter.new Twilio::REST::Client.new(sid, token)
