require 'rom-sql'
require 'rom-repository'

class Sessions < ROM::Relation[:sql]
  schema(infer: true)

  def by_uuid(uuid) 
    where(uuid: uuid) 
  end
end


module Repositories
  class Sessions < ROM::Repository[:sessions]
    commands :create, :update, :delete

    def all 
      sessions.to_a
    end

    def query(condition)
      sessions.where(condition)
    end

    def [](uuid)
      sessions.by_uuid(uuid).one!
    end
  end
end



class Entity
  @@config = ROM::Configuration.new(:sql, ENV['pg_dsn'])
  @@config.register_relation Sessions
  
  def self.container
    @@container ||= ROM.container(@@config)
  end

  def self.sessions
    Repositories::Sessions.new(container)
  end
end
