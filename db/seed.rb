require 'sequel'
require 'uuid'

DB = Sequel.connect('sqlite://db/development.db')
DATA_PATH = File.expand_path('../../test/data', __FILE__)
UPLOAD_PATH = File.expand_path('../../tmp/uploads', __FILE__)

Sequel.extension :migration
Sequel::Migrator.check_current(DB, 'db/migrate')

points_of_interest = [
  { :title          => 'Statue of Liberty',
    :image_filename => 'statue-of-liberty.jpg',
    :latitude       => 40.689199,
    :longitude      => -74.044517 },

  { :title          => 'Central Park',
    :image_filename => 'central-park.jpg',
    :latitude       => 40.771312,
    :longitude      => -73.973780 },

  { :title          => 'Empire State Building',
    :image_filename => 'empire-state-building.jpg',
    :latitude       => 40.748433,
    :longitude      => -73.985656 },

  { :title          => 'Museum of Modern Art',
    :image_filename => 'museum-of-modern-art.jpg',
    :latitude       => 40.768697,
    :longitude      => -73.991818 },

  { :title          => 'Rockerfeller Plaza',
    :image_filename => 'rockerfeller-plaza.jpg',
    :latitude       => 40.758956,
    :longitude      => -73.979464 },

  { :title          => 'Madison Square Garden',
    :image_filename => 'madison-square-garden.jpg',
    :latitude       => 40.752249,
    :longitude      => -73.995682 },

  { :title          => 'Radio City Music Hall',
    :image_filename => 'radio-city-music-hall.jpg',
    :latitude       => 40.759908,
    :longitude      => -73.980293 },

  { :title          => 'Cyrus Innovation',
    :image_filename => 'cyrus-innovation.jpg',
    :latitude       => 40.728295,
    :longitude      => -74.005197 }
]

points_of_interest.each do |location|
  uuid = UUID.new.generate
  filename_with_uuid = "#{uuid}-#{location[:image_filename]}"

  FileUtils.cp(
    File.join(DATA_PATH, location[:image_filename]),
    File.join(UPLOAD_PATH, filename_with_uuid)
  )

  DB[:photos] << {
    :uuid         => uuid,
    :content_type => 'image/jpeg',
    :file_size    => File.size(File.join(DATA_PATH, location[:image_filename])),
    :filename     => filename_with_uuid,
    :title        => location[:title],
    :latitude     => location[:latitude],
    :longitude    => location[:longitude],
    :created_at   => Time.new,
    :updated_at   => Time.new,
    :url          => "/tmp/uploads/#{filename_with_uuid}"
  }
end

puts "<= Database seeded."
