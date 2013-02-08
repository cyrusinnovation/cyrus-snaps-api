require 'sequel'
require 'uuid'

DB = Sequel.connect('sqlite://db/development.db')
FILE_PATH = File.expand_path('../../test/data', __FILE__)

Sequel.extension :migration
Sequel::Migrator.check_current(DB, 'db/migrate')

filenames = %w[test_image.png]

filenames.each do |file|
  DB[:photos] << {
    :uuid         => UUID.new.generate,
    :content_type => 'image/png',
    :file_size    => File.size(File.join(FILE_PATH, file)),
    :filename     => file,
    :latitude     => 40.5387689,
    :longitude    => -74.3157092,
    :created_at   => Time.new,
    :updated_at   => Time.new,
    :url          => "/tmp/uploads/#{file}"
  }
end
