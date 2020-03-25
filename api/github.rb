require_relative '../db/entity'
require 'octokit'
require 'json'
require_relative '../db/sequel/repos'

module Dossier
  module MeRoutes
    def self.registered(app)
      app.get "/api/me/info" do 
        protected!
        me = Entity.users.find_by_id(@session_entity[:user_id])
        payload = me.select{ |key, _ | [:id, :login].include? key }
        json(payload.to_json)
      end

      app.get "/api/me/repos" do
        protected!
        query_payload = {
          per_page: params[:per_page] || 10,
          offset: params[:offset] || 0,
          id: @session_entity[:user_id]
        }
        repos = Entity.repos.find_by_user(query_payload)
        json repos.to_json
      end

      app.post "/api/me/reports/new" do 
        protected!
        body = JSON.parse(request.body.read, symbolize_names: true)
        puts body.inspect
        id = Entity.create_report(body, @session_entity[:user_id])
        if id
          json ({ id: id }).to_json
        else
          halt 401, "unauthorized"
        end
      end

      app.get "/api/me/sync_repos" do 
        protected!
        Entity.sync_repos(@session_entity[:user_id])
      end

      app.get "/api/me/repos/count" do 
        protected!
        count = Entity.repos.count_by_user(@session_entity[:user_id])
        json count.to_h.to_json
      end

      app.post "/api/dossier/:token" do 
        token = params[:token]
        payload = JSON.parse(request.body.read, symbolize_names: true)
        id = Entity.report_datas.create(token, payload)
        json id.to_json
      end
    end
  end
end