require 'sequel'

class Database
  class << self
    def resource
      @@db ||= Sequel.connect(ENV['pg_dsn'])
    end
  end
end