require 'octokit'
require_relative 'sequel/repos'
require_relative 'sequel/sessions'
require_relative 'sequel/users'
require_relative 'sequel/users_repos'
require_relative 'sequel/reports'
require_relative 'sequel/report_datas'
class Entity
  class << self
    def users_repos
      UsersRepos
    end

    def sessions
      Sessions
    end
    
    def repos
      Repos
    end

    def users
      Users
    end

    def reports
      Reports
    end

    def report_datas
      ReportDatas
    end

    def create_report(payload, user_id) 
      repo_id = payload[:repo_id]
      belongs = repos.belong_to_user(repo_id, user_id)
      unless belongs.nil?
        reports.create(payload)
      else
        nil
      end
    end

    def sync_repos(user_id, type="GITHUB")
      user = users.find_by_id(user_id)
      client = Octokit::Client.new(access_token: user[:access_token])
      repositories = client.repositories
      repos_to_sync = repositories.map do |repo| 
        { 
          owner: repo.owner.login,
          name: repo.name,
          resource_id: repo.id,
          type: type,
          url: repo.html_url
        }
      end

      ids = self.repos.sync(repos_to_sync)
      pp ids
      sync_user_repos = ids.map do |id|
        { user_id: user[:id], repo_id: id }
      end
      self.users_repos.sync(sync_user_repos)
      true
    end

  end
end