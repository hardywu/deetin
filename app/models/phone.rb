class Phone < ApplicationRecord
  belongs_to :user

  validates :number, phone: true

  after_initialize  :generate_code
  before_validation :parse_country
  before_validation :sanitize_number

  scope :verified, -> { where.not(validated_at: nil) }

  def regenerate_code
    generate_code
    save
  end

  # FIXME: Clean code below
  class << self
    def sanitize(unsafe_phone)
      unsafe_phone.to_s.gsub(/\D/, '')
    end

    def parse(unsafe_phone)
      Phonelib.parse sanitize(unsafe_phone)
    end

    def valid?(unsafe_phone)
      parse(unsafe_phone).valid?
    end

    def international(unsafe_phone)
      parse(unsafe_phone).international(false)
    end

    def send_confirmation_sms(phone)
      Rails.logger.info(
        "Sending SMS to #{phone.number} with code #{phone.code}"
      )

      app_name = Rails.application.class.parent.to_s
      send_sms(number: phone.number,
               content: "Your verification code for #{app_name}: #{phone.code}")
    end

    def send_sms(number:, content:)
      @sms_client.send_sms(
        to: '+' + number,
        body: content
      )
    end
  end

  private

  def generate_code
    self.code = rand.to_s[2..6]
  end

  def parse_country
    data = Phonelib.parse(number)
    self.country = data.country
  end

  def sanitize_number
    self.number = Phone.sanitize(number)
  end
end
