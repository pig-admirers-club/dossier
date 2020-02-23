require_relative '../lib/jwt'
require_relative '../db/entity'
require 'octokit'

module Pickled
  module OauthRoutes
    def self.registered(app)
      app.get "/api/oauth/start" do 
        client = PickledAuth.get_client
        redirect_url = client.auth_code.authorize_url
        redirect redirect_url
      end

      app.get "/api/oauth/callback" do 
        code = request.env['rack.request.query_hash']['code']
        token = PickledAuth.get_token(code).token
        client = Octokit::Client.new(access_token: token)
        payload = { 
          login: client.user.login,
          token: token
        }
        user = Entity.users.find_or_create(payload)

        Entity.sessions.query(user_id: user.id).delete
        session_entity = Entity.sessions.create(user_id: user.id)
        cookies[:session] = session_entity.uuid
        Entity.sync_repos(user.id)
        redirect '/'
      end
    end
  end
end