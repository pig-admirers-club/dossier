require_relative '../db/entity'

module Dossier
  module ReportRoutes
    def self.registered(app)
      app.get '/api/reports/:id/count' do
        id = params[:id].to_i
        count = Entity.reports.count(id)
        json count.to_json
      end

      app.get '/api/reports/:id' do 
        query_payload = {
          per_page: params[:per_page] || 10,
          offset: params[:offset] || 0,
          id: params[:id]
        }
        reports = Entity.report_datas.get_all(query_payload).map do |data|
          { 
            uuid: data[:id],
            features: JSON.parse(data[:data]),
            date: data[:created]
          }
        end
        json reports.to_json
      end
    end
  end
end
