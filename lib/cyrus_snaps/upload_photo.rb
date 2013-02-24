module CyrusSnaps
  class UploadPhoto
    # TODO:
    # * Validate the photo?
    # * What happens if upload fails?
    attr_reader :title, :coordinates, :payload_file, :album

    def self.call(info, payload_file)
      self.new(info, payload_file).call
    end

    def initialize(info, payload_file, album=DB[:photos])
      payload_file[:filename] = "#{uuid}-#{payload_file[:filename]}"
      @title = info['title']
      @coordinates = info['coordinates']
      @album = album
      @payload_file = payload_file
    end

    def call
      uploader.store!(payload_file)

      album << {
        :uuid         => uuid,
        :title        => title,
        :latitude     => coordinates.latitude,
        :longitude    => coordinates.longitude,
        :filename     => payload_file[:filename],
        :created_at   => Time.now,
        :updated_at   => Time.now,
        :content_type => payload_file[:type],
        :file_size    => File.size(payload_file[:tempfile]),
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
  end
end
