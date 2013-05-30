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

  desc 'Drop the development database and local image files in /tmp/uploads'
  task :drop do
    exec('rm db/development.db && rm tmp/uploads/*')
  end

  desc 'Seed the database according to db/seeds.rb'
  task :seed do
    exec('ruby db/seed.rb')
  end
end
