require "rake/testtask"
require "rdoc/task"

DEFAULT_TASKS    = %w[test flog flay]
MAIN_RDOC        = 'README.rdoc'
EXTRA_RDOC_FILES = [MAIN_RDOC]
LIB_FILES        = Dir["lib/**/*.rb"]
TEST_FILES       = Dir["test/**/*_test.rb"]
TITLE            = 'Cyrus Snaps'

# Import external rake tasks
Dir.glob('tasks/*.rake').each { |r| import r }

desc "Default tasks: #{DEFAULT_TASKS.join(', ')}"
task :default => DEFAULT_TASKS

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = TEST_FILES
end

RDoc::Task.new do |t|
  t.main = MAIN_RDOC
  t.rdoc_dir = 'doc'
  t.rdoc_files.include(EXTRA_RDOC_FILES, LIB_FILES)
  t.options << '-q'
  t.title = TITLE
end

unless 'production' == ENV['RACK_ENV']
  require "flay_task"
  FlayTask.new do |t|
    t.dirs = %w[lib]
  end

  require "flog"
  desc 'Analyze code using ABC metric'
  task :flog do
    flog = Flog.new
    flog.flog ['lib']
    threshold = 50

    bad_methods = flog.totals.select do |name, score|
      score > threshold
    end

    bad_methods.sort do |a, b|
      a[1] <=> b[1]
    end.each do |name, score|
      puts "%8.1f: %s" % [score, name]
    end

    unless bad_methods.empty?
      raise "#{bad_methods.size} methods have a flog complexity > #{threshold}"
    end
  end
end

namespace :db do
  require 'sequel'

  Sequel.extension :migration
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/development.db')

  desc 'Migrate the database to latest version'
  task :migrate do
    Sequel::Migrator.run(DB, 'db/migrate')
    puts '<= db:migrate executed'
  end

  desc 'Perform migration reset (full erase and migration up)'
  task :reset do
    Sequel::Migrator.run(DB, 'db/migrate', :target => 0)
    Sequel::Migrator.run(DB, 'db/migrate')
    puts '<= db:reset executed'
  end
end
