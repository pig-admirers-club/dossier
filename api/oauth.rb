require_relative '../lib/auth'
require_relative '../db/entity'
require 'octokit'

module Dossier
  module OauthRoutes
    def self.registered(app)
      app.get "/api/oauth/start" do 
        redirect_url = DossierAuth.get_client_url
        redirect redirect_url
      end

      app.get "/api/oauth/callback" do 
        code = request.env['rack.request.query_hash']['code']
        token = Octokit.exchange_code_for_token(code, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'])
        client = Octokit::Client.new(access_token: token[:access_token])
        puts client.inspect
        payload = { 
          login: client.user.login,
          token: token[:access_token]
        }
        user = Entity.users.find_or_create(payload)

        Entity.sessions.delete_by_user_id(user[:id])
        session_entity = Entity.sessions.create(user[:id])
        cookies[:session] = session_entity[:uuid]
        Entity.sync_repos(user[:id])
        redirect '/'
      end
    end
  end
end