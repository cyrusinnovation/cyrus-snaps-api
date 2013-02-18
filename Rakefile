require "rake/testtask"
require "rdoc/task"

DEFAULT_TASKS    = %w[test:all flog flay]
MAIN_RDOC        = 'README.rdoc'
EXTRA_RDOC_FILES = [MAIN_RDOC]
LIB_FILES        = Dir["lib/**/*.rb"]
TITLE            = 'Cyrus Snaps'

# Import external rake tasks
Dir.glob('tasks/*.rake').each { |r| import r }

desc "Default tasks: #{DEFAULT_TASKS.join(', ')}"
task :default => DEFAULT_TASKS

namespace :test do
  namespace :server do
    pid = -1
    task :start do
      ENV['RACK_ENV'] = 'test'
      pid = fork { exec 'bundle exec rackup -p 3000 config.ru' }
      puts "\n<= Server starting with PID ##{pid}"
      sleep 2
    end

    task :stop do
      if -1 == pid
        puts "\n<= No server to stop; PID is #{pid}"
      else
        print "\n<= Stopping server with PID ##{pid}..."
        Process.kill "TERM", pid
        Process.wait pid
        puts "stopped"
      end
    end
  end

  Rake::TestTask.new(:unit) do |t|
    t.libs << 'test'
    t.test_files = Dir["test/unit/**/*_test.rb"]
  end

  Rake::TestTask.new(:functional) do |t|
    t.libs << 'test'
    t.test_files = Dir["test/functional/**/*_test.rb"]
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs << 'test'
    t.test_files = Dir["test/integration/**/*_test.rb"]
  end

  desc "Run all tests"
  task :all => %w[test:unit test:functional test:integration]
end

task 'test:integration' => ['test:server:start']

Rake::Task['test:integration'].enhance do |t|
  Rake.application['test:server:stop'].execute
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
