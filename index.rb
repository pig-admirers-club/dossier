require 'sinatra/base'
require_relative './api/oauth'
require_relative './api/github'
require 'dotenv'
require_relative './lib/auth'
require 'octokit'
require 'oauth2'
require_relative 'db/entity'
require 'sinatra/cookies'
require 'sinatra/json'
Dotenv.load

class DossierServer < Sinatra::Base
  helpers Sinatra::Cookies
  helpers Sinatra::JSON
  register Dossier::OauthRoutes
  register Dossier::MeRoutes
  enable :sessions

  Octokit.configure do |c|
    c.auto_paginate = true
  end


  helpers do
    def protected!
      @session_id = cookies[:session]
      if @session_id
        @session_entity = Entity.sessions.get(@session_id)
        puts @session_entity.inspect
      end
      unless @session_id && @session_entity
        halt 401, "Not authorized"
      end
    end
  end

  get '/' do 
    erb :index
  end

  get '/ruby-cucumber/:id' do 
    report = Entity.reports.get_with_repo_by_id(params[:id])
    erb :ruby_cucumber, locals: { report: report }
  end

  get '/api/dossier/:report_id' do
    reports = Entity.report_datas.get_all(params[:report_id]).map do |data|
      { 
        uuid: data[:id],
        features: JSON.parse(data[:data]),
        date: data[:created]
      }
    end

    json reports.to_json
  end

  run! if app_file == $0
end