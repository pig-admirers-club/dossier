# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :repos do
      primary_key :id
      column :type, String, null: false
      column :owner, String, null: false
      column :name, String, null: false
      column :url, String, null: false
      column :resource_id, Integer, null: false
      unique [:resource_id, :type], name: 'unique_repo'
    end
  end
end
