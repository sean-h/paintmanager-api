require 'rake/testtask'
require 'sinatra/activerecord'
require 'active_record/fixtures'

task :environment, [:env] do |t, args|
  desc 'Setup server environment'
  db_config = YAML::load(File.open('db/config.yml'))
  ActiveRecord::Base.establish_connection(db_config[args[:env]])
end

Rake::TestTask.new do |t|
  Rake::Task[:environment].invoke('test')
  fixtures = ['brands', 'ranges', 'paints']
  ActiveRecord::FixtureSet.create_fixtures('test/fixtures', fixtures)
  t.libs << 'test'
  t.test_files = FileList['test/test_*.rb']
end

namespace :db do
  desc 'Migrate the database'
  task :migrate, [:env] => :environment do |t, args|
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate('db/migrate')
  end
end
