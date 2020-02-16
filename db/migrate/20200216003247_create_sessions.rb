# frozen_string_literal: true
ROM::SQL.migration do
  up do
    run 'CREATE EXTENSION "uuid-ossp"'
    create_table :sessions do 
      column :uuid, :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      column :access_token, String, null: false
      column :created, DateTime, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  down do 
    run 'DROP EXTENSION IF EXISTS "uuid-ossp"'
    drop_table :sessions
  end
end
