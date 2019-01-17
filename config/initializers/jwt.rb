key = OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV['JWT_PUBLIC_KEY']))
raise ArgumentError, 'JWT_PUBLIC_KEY was private key, however it should be public.' if key.private?
Rails.configuration.jwt_public_key = key
