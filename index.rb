require 'sinatra/base'
require_relative './api/oauth'
require 'dotenv'
require_relative './lib/jwt'
require 'octokit'
require 'oauth2'
require_relative 'db/entity'
require 'sinatra/cookies'
Dotenv.load

class PickledServer < Sinatra::Base
  helpers Sinatra::Cookies
  register Pickled::OauthRoutes
  enable :sessions

  get '/' do 
    pp Entity.sessions.all

    session_id = cookies[:session]
    session_entity = Entity.sessions[session_id] if session_id

    unless session_id && session_entity
      client = PickledAuth.get_client
      redirect_url = client.auth_code.authorize_url
      redirect redirect_url
    else
      client = Octokit::Client.new(access_token: session_entity.access_token)
      repos = client.repositories
      "#{repos.map(&:name).join('<br>')}"
    end
  end

  run! if app_file == $0
end