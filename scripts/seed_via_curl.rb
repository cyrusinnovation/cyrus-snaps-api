BASE_URL  = 'http://agile-wave-5535.herokuapp.com'
DATA_PATH = File.expand_path('../../test/data', __FILE__)

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
  filename = File.join(DATA_PATH, location[:image_filename])

  resp = `curl -i\
    -F photo[title]='#{location[:title]}'\
    -F photo[latitude]=#{location[:latitude]}\
    -F photo[longitude]=#{location[:longitude]}\
    -F 'photo[image]=@#{filename};type=image/png'\
    #{BASE_URL}/photos`

  #if resp.include?('201 Created')
    #puts "successfully uploaded #{location[:title]}"
  #else
    #puts "There was an error with upload:\n#{resp}"
  #end
end
