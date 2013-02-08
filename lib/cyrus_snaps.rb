require 'carrierwave'
require 'json'
require 'sequel'
require 'sinatra/base'

require_relative 'cyrus_snaps/coordinates'
require_relative 'cyrus_snaps/photo_query'
require_relative 'cyrus_snaps/upload_photo'

module CyrusSnaps
  unless ENV['RACK_ENV'] == 'test'
    DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/development.db')
  end

  class Server < Sinatra::Base
    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader

      CarrierWave.configure do |config|
        config.cache_dir   = 'tmp/cache'
        config.storage     = :file
        config.store_dir   = 'tmp/uploads'
      end
    end

    configure :production do
      enable :logging

      CarrierWave.configure do |config|
        config.fog_credentials = {
          :provider              => 'AWS',
          :aws_access_key_id     => ENV['S3_KEY'],
          :aws_secret_access_key => ENV['S3_SECRET']
        }

        config.cache_dir     = 'tmp/cache'
        config.storage       = :fog
        config.fog_directory = 'com.bobnadler.cyrus_snaps'
      end
    end

    configure do
      Sequel.extension :migration
      Sequel::Migrator.check_current(DB, 'db/migrate')
    end

    before { content_type :json }

    get '/photos' do
      JSON.generate(photo_query.all)
    end

    get '/photos/:uuid' do
      # TODO: What happens if the photo is not found?
      JSON.generate({ :photo => photo_query.by_uuid(params[:uuid]) })
    end

    post '/photos' do
      photo = params[:photo]
      coordinates = Coordinates.new(photo[:latitude], photo[:longitude])
      UploadPhoto.call(coordinates, photo[:image])
      201
    end

    private

    def photo_query
      @photo_query ||= PhotoQuery.new
    end
  end
end
