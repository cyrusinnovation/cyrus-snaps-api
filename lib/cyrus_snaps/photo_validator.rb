module CyrusSnaps
  class PhotoValidator
    include Validus

    attr_reader :title, :image

    def initialize(attributes)
      attrs = attributes || {}
      @title = attrs[:title] || nil
      @image = attrs[:image] || nil
    end

    def validate
      errors.add(:title, "can't be blank") if title.nil? || '' == title
      errors.add(:image, "is required") if image.nil?
    end
  end
end
