module CyrusSnaps
  class UploadPhoto
    attr_reader :params, :album

    def self.call(params, album=DB[:photos])
      self.new(params, album).call
    end

    def initialize(params, album)
      @params = params
      @album  = album
    end

    def call
      params[:image][:filename] = filename_with_uuid
      uploader.store!(params[:image])
      album << {
        :uuid         => uuid,
        :title        => params[:title],
        :latitude     => params[:latitude],
        :longitude    => params[:longitude],
        :created_at   => Time.now,
        :updated_at   => Time.now,
        :filename     => filename_with_uuid,
        :content_type => params[:image][:type],
        :file_size    => File.size(params[:image][:tempfile]),
        :url          => uploader.url
      }

      uuid
    end

    private

    def uploader
      @uploader ||= CarrierWave::Uploader::Base.new
    end

    def uuid
      @uuid ||= UUID.new.generate
    end

    def filename_with_uuid
      @filename_with_uuid ||= "#{uuid}-#{params[:image][:filename]}"
    end
  end
end
