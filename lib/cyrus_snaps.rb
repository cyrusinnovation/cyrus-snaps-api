require 'carrierwave'
require 'json'
require 'sequel'
require 'sinatra/base'
require 'uuid'

require_relative 'cyrus_snaps/photo_query'
require_relative 'cyrus_snaps/upload_photo'

module CyrusSnaps
  class Server < Sinatra::Base
    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader

      CarrierWave.configure do |config|
        config.cache_dir = 'tmp/cache'
        config.root      = File.expand_path('../../', __FILE__)
        config.storage   = :file
        config.store_dir = 'tmp/uploads'
      end

      get '/tmp/uploads/:filename' do
        file = File.expand_path("../../tmp/uploads/#{params[:filename]}", __FILE__)
        halt(404, "Can't find #{file}") unless File.exist?(file)
        content_type :png
        send_file(file)
      end
    end

    configure :test do
      CarrierWave.configure do |config|
        config.cache_dir = 'tmp/cache'
        config.root      = File.expand_path('../../', __FILE__)
        config.storage   = :file
        config.store_dir = 'tmp/uploads'
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

    before { content_type :json }

    get '/photos' do
      JSON.generate(photo_query.all)
    end

    get '/photos/:uuid' do
      # TODO: What happens if the photo is not found?
      JSON.generate(photo_query.by_uuid(params[:uuid]))
    end

    post '/photos' do
      UploadPhoto.call(params[:photo])
      201
    end

    private

    def photo_query
      @photo_query ||= PhotoQuery.new
    end
  end
end
