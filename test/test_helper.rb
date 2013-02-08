ENV['RACK_ENV']     = 'test'
ENV['DATABASE_URL'] = 'sqlite:/'

require 'bundler/setup'

require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end

require 'test/unit'
require 'carrierwave'
require 'contest'
require 'mocha/setup'
require 'sequel'

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

TEST_DATA_DIR = File.expand_path('../data', __FILE__)

CarrierWave.configure do |config|
  config.cache_dir = 'tmp/cache'
  config.root      = File.expand_path('../../', __FILE__)
  config.storage   = :file
  config.store_dir = 'tmp/uploads'
end

Sequel.extension :migration
DB = Sequel.sqlite.tap do |db|
  Sequel::Migrator.run(db, 'db/migrate')
  puts '<= in memory test database created'
end

class Test::Unit::TestCase
  # Syntactic sugar for defining a memoized helper method.
  def self.let(name, &block)
    ivar = "@#{name}"
    self.class_eval do
      define_method(name) do
        if instance_variable_defined?(ivar)
          instance_variable_get(ivar)
        else
          value = self.instance_eval(&block)
          instance_variable_set(ivar, value)
        end
      end
    end
  end
end
