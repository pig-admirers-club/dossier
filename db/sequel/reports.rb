require_relative 'db'
require 'digest'
class Reports
  class << self
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
      data[:token] = Digest::SHA1.hexdigest([Time.now, rand].join)
      sql = <<-END
        insert into reports(repo_id, name, framework, token) values (:repo_id, :name, :framework, :token) returning id
      END
      Database.resource[sql, data].first
    end
  end
end
