require_relative 'db'
require 'digest'
require_relative '../../lib/validator'

class Reports

  CREATE_VALIDATOR = Dossier::Validator.new({
    required: [
      { field: :repo_id, message: 'Repository must be selected' },
      { field: :name, message: 'Report name is required' },
      { field: :framework, message: 'Report Framework is required' }
    ],
    match: [
      { field: :name, message: 'Report name must not have leading or trailing spaces', regex: /^[^\s]+[\w|-|_|\s]+[^\s]+$/}
    ]
  })

  class << self

    def count(id)
      sql = <<-END
        select count(rd.id) from reports as r 
        inner join report_datas as rd on rd.report_id = r.id 
        where r.id = ?
      END
      Database.resource[sql, id].first
    end
    def get_with_repo_by_id(report_id)
      sql = <<-END
        select rp.id, rp.name, rp.framework, re.type, re.owner, re.name as repo_name, re.url from reports as rp
        inner join repos as re
        on re.id = rp.repo_id
        where rp.id = ?
      END
      Database.resource[sql, report_id].first
    end

    def create(data)
      CREATE_VALIDATOR.validate(data)
      data[:token] = Digest::SHA1.hexdigest([Time.now, rand].join)
      sql = <<-END
        insert into reports(repo_id, name, framework, token) values (:repo_id, :name, :framework, :token) returning id
      END
      Database.resource[sql, data].first
    end
  end
end
