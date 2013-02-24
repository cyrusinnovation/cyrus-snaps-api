require 'test_helper'
require 'rack/test'

require 'uuid'

require 'cyrus_snaps/coordinates'
require 'cyrus_snaps/upload_photo'

module CyrusSnaps
  class UploadPhotoTest < Test::Unit::TestCase
    let(:payload) do
      filename = File.join(TEST_DATA_DIR, 'test_image.png')
      image = Rack::Test::UploadedFile.new(filename, 'image/png')

      {
        :filename => image.original_filename,
        :type     => image.content_type,
        :tempfile => image
      }
    end

    let(:coordinates) { Coordinates.new(1.234, 2.345) }
    let(:album) { [] }
    let(:now) { Time.new }

    let(:photo) do
      uuid = UploadPhoto.new(coordinates, payload, album).call
      album.first
    end

    setup do
      Time.stubs(:now).returns(now)
      UUID.any_instance.expects(:generate).returns('abc-123')
    end

    test "returns uuid" do
      result = UploadPhoto.new(coordinates, payload, album).call
      assert_equal('abc-123', result)
    end

    test "assigns timestamps" do
      assert_equal(now, photo[:created_at])
      assert_equal(now, photo[:updated_at])
    end

    test "extracts coordinates" do
      assert_equal(1.234, photo[:latitude])
      assert_equal(2.345, photo[:longitude])
    end

    test "extracts payload information" do
      assert_equal('abc-123-test_image.png', photo[:filename])
      assert_equal('image/png', photo[:content_type])
      assert_equal(6753, photo[:file_size])
    end

    test "stores the image on file system" do
      filename = File.expand_path(
        '../../../tmp/uploads/abc-123-test_image.png', __FILE__)

      assert(File.exists?(filename), "expected #{filename} to exist")
      assert_equal('/tmp/uploads/abc-123-test_image.png', photo[:url])
    end

    test "stores the photo in the album" do
      assert_not_nil(photo, "expected #{album} to include #{photo}")
      assert_equal(1, album.size)
    end
  end
end
