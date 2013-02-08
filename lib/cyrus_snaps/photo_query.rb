module CyrusSnaps
  class PhotoQuery
    attr_reader :album

    def initialize(album=DB[:photos])
      @album = album
    end

    def all
      album.all
    end

    def by_uuid(uuid)
      album.where(:uuid => uuid).first
    end
  end
end
