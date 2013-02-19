module CyrusSnaps
  class UploadPhoto
    # TODO:
    # * Validate the photo?
    # * What happens if upload fails?
    attr_reader :coordinates, :payload, :album

    def self.call(coordinates, payload)
      self.new(coordinates, payload).call
    end

    def initialize(coordinates, payload, album=DB[:photos])
      @coordinates = coordinates
      @album = album
      @payload = payload
    end

    def call
      uploader.store!(payload)

      album << {
        :uuid => uuid,
        :latitude => coordinates.latitude,
        :longitude => coordinates.longitude,
        :filename => payload[:filename],
        :created_at => Time.now,
        :updated_at => Time.now,
        :content_type => payload[:type],
        :file_size => File.size(payload[:tempfile]),
        :url => uploader.url
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
  end
end
