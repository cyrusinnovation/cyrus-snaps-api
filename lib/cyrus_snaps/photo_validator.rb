module CyrusSnaps
  class PhotoValidator
    include Validus

    attr_reader :title, :image

    def initialize(attrs={})
      @title = attrs[:title]
      @image = attrs[:image]
    end

    def validate
      errors.add(:title, "can't be blank") if title.nil? || '' == title
      errors.add(:image, "is required") if image.nil?
    end
  end
end
