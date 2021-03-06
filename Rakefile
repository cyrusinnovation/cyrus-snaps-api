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
    task :start do
      ENV['RACK_ENV'] = 'test'
      pid = fork { exec 'bundle exec rackup --port 3000 --pid test_server.pid config.ru' }
      puts "\n<= Server starting with PID ##{pid}"
      sleep 2
    end

    task :stop do
      if File.exist?('test_server.pid')
        pid = File.read('test_server.pid').to_i
        print "\n<= Stopping server with PID ##{pid}..."
        Process.kill "TERM", pid
        puts "stopped"
      else
        puts "\n<= No server to stop"
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
