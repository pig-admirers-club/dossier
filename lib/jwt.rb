require 'openssl'
require 'jwt'
require 'oauth2'

class PickledAuth
  def self.get_token(code)
    client = self.get_client
    client.auth_code.get_token(code)
  end

  def self.get_client
    opts = {
      site: 'https://www.github.com',
      authorize_url: 'login/oauth/authorize',
      token_url: 'login/oauth/access_token'
    }

    OAuth2::Client.new(ENV['client_id'], ENV['client_secret'], opts)
  end

  def self.get_jwt
    private_pem = File.read(ENV['app_private_key'])
    private_key = OpenSSL::PKey::RSA.new(private_pem)

    payload = {
      iat: Time.now.to_i,
      exp: Time.now.to_i + (10 * 60),
      iss: ENV['app_id']
    }

    JWT.encode(payload, private_key, "RS256")
  end
end