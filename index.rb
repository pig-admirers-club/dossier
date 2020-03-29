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

if Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = 9999999999999999
end

class DossierServer < Sinatra::Base
  set :bind, '0.0.0.0'

  helpers Sinatra::Cookies
  helpers Sinatra::JSON
  register Dossier::OauthRoutes
  register Dossier::MeRoutes
  enable :sessions

  Octokit.configure do |c|
    c.auto_paginate = true
    c.api_endpoint = ENV['GITHUB_API_URL'] if ENV['GITHUB_API_URL']
    c.web_endpoint = ENV['GITHUB_WEB_URL'] if ENV['GITHUB_WEB_URL']
  end


  helpers do
    def logged_in?
      @session_id = cookies[:session]
      if @session_id
        @session_entity = Entity.sessions.get(@session_id)
        puts @session_entity.inspect
      end
      @session_id && @session_entity
    end

    def protected!
      halt(401, "Not authorized") unless !!logged_in?
    end
  end

  get '/' do
    erb (logged_in? ? :index : :splash)
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