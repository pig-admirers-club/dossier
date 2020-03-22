require_relative 'db'

class ReportDatas
  class << self

    def get_all(report_id) 
      Database.resource['select * from report_datas where report_id = ?', report_id].all
    end

    def create(token, data)

      report = Database.resource['select id from reports where token = ?', token].first
      return unless report[:id]
      
      data[:report_id] = report[:id]
      data[:payload] = data[:payload].to_json

      sql = <<-END
        insert into report_datas (report_id, data) values (:report_id, :payload) returning id
      END
      Database.resource[sql, data].first
    end
  end
end