# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :users do 
      primary_key :id
      column :login, String, null: false
      column :created, DateTime, default: Sequel::CURRENT_TIMESTAMP
      column :access_token, String, null: false
    end
  end
end
