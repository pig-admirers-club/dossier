require_relative '../lib/jwt'
require_relative '../db/entity'

module Pickled
  module OauthRoutes
    def self.registered(app)
      app.get "/api/oauth/callback" do 
        code = request.env['rack.request.query_hash']['code']
        token = PickledAuth.get_token(code).token

        Entity.sessions.query(access_token: token).delete
        record = Entity.sessions.create(access_token: token)
        cookies[:session] = record.uuid
        session[:access_token] = "GOOD JOB"
        redirect '/'
      end
    end
  end
end