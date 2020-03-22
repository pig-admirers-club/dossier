require_relative 'db'

class Sessions
  class << self
    def create(user_id) 
      sql = <<-END
        insert into sessions (user_id) values (?) returning *
      END
      Database.resource[sql, user_id].all.first
    end

    def get(id)
      sql = <<-END
        select * from sessions where uuid = ? limit 1
      END
      Database.resource[sql, id].all.first
    end

    def find_by_user_id(id)
      sql = <<-END
        select * from sessions where user_id = ?
      END
      Database.resource[sql, id].all.first
    end

    def delete_by_user_id(id)
      sql = <<-END
        delete from sessions where user_id = ?
      END
      Database.resource[sql, id].first
    end
  end
end