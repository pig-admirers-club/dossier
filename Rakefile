require 'rom/sql/rake_task'
require 'rom'
require 'dotenv'
Dotenv.load

namespace :db do 
  task :setup do
    ROM::SQL::RakeSupport.env = ROM.container(:sql, ENV['pg_dsn'])
  end
end
