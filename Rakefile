require 'rom/sql/rake_task'
require 'rom'
require 'dotenv'
Dotenv.load

namespace :db do 
  task :setup do
    dsn = (ENV['test'].eql? 'true') ? ENV['pg_test_dsn'] : ENV['pg_dsn']
    ROM::SQL::RakeSupport.env = ROM.container(:sql, dsn)
  end
end

