# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_enum(
      :frameworks, 
      %w|RubyCucumber|
    )
    create_table :reports do 
      primary_key :id
      foreign_key :repo_id, :repos, null: false
      column :token, String, null: false
      column :name, String, null: false
      frameworks :framework
    end
  end
end
