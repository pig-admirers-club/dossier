require_relative 'db'

class Users
  class << self
    def get_all
      sql = <<-END
        select * from repos
      END
      Database.resource[sql].all
    end

    def find_or_create(payload)
      user = find_by_username(payload[:login])
      if user 
        if !(user[:access_token].eql? payload[:token])
          sql = <<-END
            update users set access_token = :token where login = :login returning id
          END
          Database.resource[sql, payload].all.first
        else
          return user
        end
      else
        sql = <<-END
          insert into users (login, access_token) values (:login, :token) returning id
        END
        Database.resource[sql, payload].all.first
      end
    end

    def find_by_id(id)
      Database.resource['select * from users where id = ?', id].all.first
    end

    def find_by_username(username)
      sql = <<-END
        select * from users where login = ?
      END
      Database.resource[sql, username].all.first
    end

    def find_by_token(token)
      sql = <<-END
        select * from users where access_token = ?
      END
      Database.resource[sql, token].all.first
    end
  end
end