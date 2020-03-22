require_relative 'db'

class UsersRepos
  class << self
    def sync(users_repos_dataset)
      Database.resource[:users_repos].insert_conflict(
        constraint: :unique_user_repo
      ).multi_insert(users_repos_dataset)
    end
  end
end
