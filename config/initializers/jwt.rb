unless ENV['JWT_PUBLIC_KEY'].blank?
  key = OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV.fetch('JWT_PUBLIC_KEY', '')))
  raise ArgumentError, 'JWT_PUBLIC_KEY was private, however it should be public.' if key.private?
  Rails.configuration.jwt_public_key = key
end
