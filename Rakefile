require 'bcrypt'
require 'rake/testtask'
require 'sinatra/activerecord'
require 'active_record/fixtures'

task :environment, :env do |t, args|
  desc 'Setup server environment'
  db_config = YAML::load(File.open('db/config.yml'))
  env = args[:env] || ENV['RACK_ENV'] || 'development'
  ActiveRecord::Base.establish_connection(db_config[env])
end

namespace :db do
  desc 'Migrate the database'
  task :migrate, [:env] => :environment do |t, args|
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate('db/migrate')
  end
end

namespace :db do
  desc 'Rollback the database'
  task :rollback, [:env] => :environment do |t, args|
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.rollback('db/migrate', 1)
  end
end

namespace :db do
  namespace :fixtures do
    desc 'Load the database fixtures'
    task :load, [:end] => :environment do |t, args|
      fixtures = ['brands', 'ranges', 'paints', 'users', 'user_tokens',
                  'compatibility_groups', 'compatibility_paints']
      ActiveRecord::FixtureSet.create_fixtures('test/fixtures', fixtures)
    end
  end
end

task :test do
  Rake::TestTask.new do |t|
    ENV['ENV'] = 'test'
    Rake::Task[:environment].invoke('test')
    Rake::Task['db:migrate'].invoke('test')
    Rake::Task['db:fixtures:load'].invoke('test')
    t.libs << 'test'
    t.test_files = FileList['test/test_*.rb']
    #Allow the environment to be set for other tasks
    Rake::Task[:environment].reenable
  end
end
