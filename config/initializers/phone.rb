require_dependency 'twilio_adapter'
require_dependency 'sms_client'

sid = ENV.fetch('TWILIO_ACCOUNT_SID', '')
token = ENV.fetch('TWILIO_AUTH_TOKEN', '')
Rails.configuration.twilio_phone_number = ENV.fetch('TWILIO_PHONE_NUMBER', '')
@sms_client = SmsClient.new TwilioAdapter.new(sid, token)
