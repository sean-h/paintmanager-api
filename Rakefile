require 'sinatra/activerecord'

task :environment do
  desc 'Setup server environment'
  db_config = YAML::load(File.open('db/config.yml'))
  ActiveRecord::Base.establish_connection(db_config["development"])
end

namespace :db do
  desc 'Migrate the database'
  task :migrate => :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate('db/migrate')
  end
end
