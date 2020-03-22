require_relative '../lib/auth'
require_relative '../db/entity'
require 'octokit'

module Dossier
  module OauthRoutes
    def self.registered(app)
      app.get "/api/oauth/start" do 
        client = DossierAuth.get_client
        redirect_url = client.auth_code.authorize_url
        redirect redirect_url
      end

      app.get "/api/oauth/callback" do 
        code = request.env['rack.request.query_hash']['code']
        token = DossierAuth.get_token(code).token
        client = Octokit::Client.new(access_token: token)
        payload = { 
          login: client.user.login,
          token: token
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