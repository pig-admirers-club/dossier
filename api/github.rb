require_relative '../db/entity'
require 'octokit'
require 'json'

module Pickled
  module MeRoutes
    def self.registered(app)
      app.get "/api/me/repos" do
        protected!
        repos = Entity.repos.find_by_user(@session_entity.user_id)
        json repos.map(&:to_h).to_json
      end

      app.get "/api/me/sync_repos" do 
        protected!
        Entity.sync_repos(@session_entity.user_id)
      end

      app.post "/api/me/repos/:id/activate" do
        protected!
        repo_id = params[:id]
        user_id = @session_entity.user_id
        repo = Entity.repos.with_user(repo_id)
        repo_users = repo.users.map(&:id)

        unless repo_users.include? user_id
          halt 401, "Unauthorized"
        end
        Entity.repos.set_active(repo_id, true)
      end

      app.post "/api/me/repos/:id/deactivate" do
        protected!
        repo_id = params[:id]
        user_id = @session_entity.user_id
        repo = Entity.repos.with_user(repo_id)
        repo_users = repo.users.map(&:id)

        unless repo_users.include? user_id
          halt 401, "Unauthorized"
        end
        Entity.repos.set_active(repo_id, false)
      end


      app.get "/api/me" do 
        protected!
        me = Entity.users.query(id: @session_entity.user_id).one
        payload = me.to_h.select{ |key, _ | [:id, :login].include? key }
        json(payload.to_json)
      end
    end
  end
end