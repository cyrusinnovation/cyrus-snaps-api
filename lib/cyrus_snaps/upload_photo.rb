module CyrusSnaps
  class UploadPhoto
    attr_reader :params, :album, :error_block

    def self.call(params, album=DB[:photos], &block)
      self.new(params, album, &block).call
    end

    def initialize(params, album, &block)
      @params      = params
      @album       = album
      @error_block = block
    end

    def call
      validator = PhotoValidator.new(params)
      if validator.valid?
        params[:image][:filename] = filename_with_uuid
        uploader.store!(params[:image])
        album << photo_hash

        return uuid
      else
        error_block.call(validator.errors.full_messages)
      end
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

    def photo_hash
      {
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
    end
  end
end
