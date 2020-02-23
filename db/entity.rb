require 'rom-sql'
require 'rom-repository'
require 'octokit'

class Sessions < ROM::Relation[:sql]
  schema(infer: true) do 
    associations do 
      belongs_to :user
    end
  end

  def by_uuid(uuid) 
    where(uuid: uuid) 
  end
end

class Users < ROM::Relation[:sql]
  schema(infer: true) do
    associations do 
      has_many :sessions
      has_many :users_repos
      has_many :repos, through: :users_repos
    end
  end

  def by_id(id)
    where(id: id)
  end

  def by_token(token) 
    where(access_token: token)
  end
end

class UsersRepos < ROM::Relation[:sql]
  schema(infer: true) do
    associations do 
      belongs_to :users
      belongs_to :repos
    end
  end
end

class Repos < ROM::Relation[:sql]
  schema(infer: true) do 
    associations do 
      has_many :users_repos
      has_many :users, through: :users_repos
    end
  end

  def get_users_repos(id)
    combine(:users).node(:users) do |users_relation|
      users_relation.where(id: id)
    end
  end

  def find_with_user(id) 
    combine(:users).where(id: id).one
  end
end

module Repositories
  class UsersRepos < ROM::Repository[:users_repos]
    def sync(user_repo_dataset)
      users_repos.dataset.insert_conflict(
        constraint: :unique_user_repo
      ).multi_insert(user_repo_dataset)
    end
  end

  class Repos < ROM::Repository[:repos]
    commands :create, :udpate, :delete, :upsert
    def query(condition) 
      repos.where(condition)
    end

    def find_by_user(id)
      repos.get_users_repos(id)
    end

    def with_user(repo_id)
      repos.find_with_user(repo_id)
    end

    def set_active(repo_id, value)
      repos.by_pk(repo_id).command(:update).call(active: value)
    end

    def sync(repo_dataset)
      repos.dataset.returning(:id).insert_conflict(
        constraint: :unique_repo,
        update: {
          owner: Sequel[:excluded][:owner],
          name: Sequel[:excluded][:name],
          url: Sequel[:excluded][:url]
        },
      ).multi_insert(repo_dataset)
    end
  end


  class Users < ROM::Repository[:users] 
    commands :create, :update, :delete

    def query(condition) 
      users.where(condition).combine(:repos)
    end

    def find_or_create(payload)
      user = users.by_token(payload[:token]).one

      unless user 
        user = create({ login: payload[:login], access_token: payload[:token] })
      end    
      user
    end
  end

  class Sessions < ROM::Repository[:sessions]
    commands :create, :update, :delete

    def all 
      sessions.to_a
    end

    def query(condition)
      sessions.where(condition)
    end

    def [](uuid)
      sessions.by_uuid(uuid).one
    end
  end
end

class Entity
  @@config = ROM::Configuration.new(:sql, ENV['pg_dsn'])
  @@config.register_relation Sessions, Users, Repos, UsersRepos
  
  def self.container
    @@container ||= ROM.container(@@config)
  end

  def self.sessions
    Repositories::Sessions.new(container)
  end

  def self.users
    Repositories::Users.new(container)
  end

  def self.repos 
    Repositories::Repos.new(container)
  end

  def self.users_repos
    Repositories::UsersRepos.new(container)
  end

  def self.sync_repos(user_id, type="GITHUB")
    user = Entity.users.query(id: user_id).one
    client = Octokit::Client.new(access_token: user.access_token)
    repos = client.repositories
    repos_to_sync = repos.map do |repo| 
      { 
        owner: repo.owner.login,
        name: repo.name,
        resource_id: repo.id,
        type: type,
        url: repo.html_url
      }
    end
    ids = self.repos.sync(repos_to_sync)
    sync_user_repos = ids.map do |id|
      { user_id: user.id, repo_id: id }
    end
    self.users_repos.sync(sync_user_repos)
    true
  end
end
