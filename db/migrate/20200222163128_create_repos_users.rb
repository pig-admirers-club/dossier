# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :users_repos do 
      primary_key :id
      foreign_key :user_id, :users, null: false
      foreign_key :repo_id, :repos, null: false
      unique [:user_id, :repo_id], name: 'unique_user_repo'
    end
  end
end
