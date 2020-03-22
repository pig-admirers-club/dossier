# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :report_datas do
      primary_key :id
      foreign_key :report_id, :reports, null: false
      jsonb :data
      column :created, DateTime, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
