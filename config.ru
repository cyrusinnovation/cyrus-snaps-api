require 'bundler/setup'
require 'sequel'
require File.expand_path('../lib/cyrus_snaps', __FILE__)

CONNECTIONS = {
  'development' => Proc.new { Sequel.connect('sqlite://db/development.db') },
  'test'        => Proc.new {
                     Sequel.connect('sqlite://db/test.db').tap do |db|
                       Sequel.extension :migration
                       Sequel::Migrator.run(db, 'db/migrate')
                       puts '<= test database created'
                     end
                   },
  'production'  => Proc.new { Sequel.connect(ENV['DATABASE_URL']) }
}

DB = CONNECTIONS[ENV['RACK_ENV']].call
Sequel.extension :migration
Sequel::Migrator.check_current(DB, 'db/migrate')

run CyrusSnaps::Server
