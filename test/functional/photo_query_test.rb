require 'test_helper'

require 'cyrus_snaps/photo_query'

module CyrusSnaps
  class PhotoQueryTest < Test::Unit::TestCase
    let(:query) { PhotoQuery.new(DB[:photos]) }

    setup do
      DB[:photos].delete
      DB[:photos] << {
        :uuid => 'abc-123',
        :content_type => 'image/png',
        :file_size => 100,
        :filename => 'test.png',
        :created_at => Time.now,
        :updated_at => Time.now,
        :url => '/uploads'
      }
    end

    test "fetches all photos" do
      actual = query.all
      assert_equal(1, actual.count)
    end

    test "fetch photo by uuid" do
      actual = query.by_uuid('abc-123')
      assert_equal('abc-123', actual[:uuid])
    end
  end
end
