require 'sinatra/base'
require_relative './api/oauth'
require_relative './api/github'
require 'dotenv'
require_relative './lib/jwt'
require 'octokit'
require 'oauth2'
require_relative 'db/entity'
require 'sinatra/cookies'
require 'sinatra/json'
Dotenv.load

class PickledServer < Sinatra::Base
  helpers Sinatra::Cookies
  helpers Sinatra::JSON
  register Pickled::OauthRoutes
  register Pickled::MeRoutes
  enable :sessions

  Octokit.configure do |c|
    c.auto_paginate = true
  end


  helpers do
    def protected!
      @session_id = cookies[:session]
      if @session_id
        @session_entity = Entity.sessions[@session_id]
      end
      unless @session_id && @session_entity
        halt 401, "Not authorized"
      end
    end
  end

  get '/' do 
    erb :index
  end

  run! if app_file == $0
end