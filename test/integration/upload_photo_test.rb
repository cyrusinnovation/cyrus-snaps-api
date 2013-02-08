require 'test_helper'
require 'rack/test'

require 'uuid'

require 'cyrus_snaps/coordinates'
require 'cyrus_snaps/upload_photo'

module CyrusSnaps
  class UploadPhotoTest < Test::Unit::TestCase
    let(:payload) do
      filename = File.join(TEST_DATA_DIR, 'test_image.png')
      Rack::Test::UploadedFile.new(filename, 'image/png')
    end

    let(:coordinates) { Coordinates.new(1.234, 2.345) }
    let(:album) { DB[:photos] }
    let(:now) { Time.new }

    let(:photo) do
      uuid = UploadPhoto.new(coordinates, payload, album).call
      album.where(:uuid => uuid).first
    end

    setup do
      Time.stubs(:now).returns(now)
    end

    test "returns uuid" do
      assert_not_nil(UploadPhoto.new(coordinates, payload, album).call,
                     "did not expect UpladPhoto#call to return nil")
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
      assert_equal('test_image.png', photo[:filename])
      assert_equal('image/png', photo[:content_type])
      assert_equal(6753, photo[:file_size])
    end

    test "stores the image on file system" do
      filename = File.expand_path('../../../tmp/uploads/test_image.png', __FILE__)
      assert(File.exists?(filename), "expected #{filename} to exist")
      assert_equal('/tmp/uploads/test_image.png', photo[:url])
    end

    test "stores the photo in the album" do
      assert_not_nil(photo, "expected #{album.all} to include #{photo}")
    end
  end
end
