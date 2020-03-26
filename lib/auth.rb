require 'openssl'
require 'jwt'
require 'oauth2'

class DossierAuth
  def self.get_client_url
    client = Octokit::Client.new
    client.authorize_url(ENV['GITHUB_CLIENT_ID'], scope: 'repo, read:org')
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