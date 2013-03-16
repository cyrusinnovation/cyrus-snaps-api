require 'test_helper'
require 'rack/test'

require 'uuid'

require 'cyrus_snaps/coordinates'
require 'cyrus_snaps/upload_photo'

module CyrusSnaps
  class UploadPhotoTest < Test::Unit::TestCase
    setup do
      File.delete(temp_filename) if File.exists?(temp_filename)
      UUID.any_instance.expects(:generate).returns('abc-123')
      Time.stubs(:now).returns(now)
      @uuid = UploadPhoto.new(params, album).call
    end

    let(:album) { [] }
    let(:now) { Time.new }
    let(:photo) { album.find { |p| 'abc-123' == p[:uuid] } }
    let(:temp_filename) { File.expand_path('../../../tmp/uploads/abc-123-test_image.png', __FILE__) }

    let(:params) do
      filename = File.join(TEST_DATA_DIR, 'test_image.png')

      {
        :title     => 'My Photo',
        :latitude  => 1.234,
        :longitude => 2.345,
        :image     => {
          :filename => File.basename(filename),
          :type     => 'image/png',
          :tempfile => Rack::Test::UploadedFile.new(filename, 'image/png')
        }
      }
    end

    test "returns uuid" do
      assert_equal('abc-123', @uuid)
    end

    test "stores the photo in the album" do
      assert_not_nil(photo, "expected #{album} to include photo with UUID abc-123")
      assert_equal(1, album.size)
    end

    test "extracts title" do
      assert_equal('My Photo', photo[:title])
    end

    test "extracts coordinates" do
      assert_equal(1.234, photo[:latitude])
      assert_equal(2.345, photo[:longitude])
    end

    test "assigns timestamps" do
      assert_equal(now, photo[:created_at])
      assert_equal(now, photo[:updated_at])
    end

    test "extracts payload file information" do
      assert_equal('abc-123-test_image.png', photo[:filename])
      assert_equal('image/png', photo[:content_type])
      assert_equal(6753, photo[:file_size])
    end

    test "stores the image on file system" do
      assert(File.exists?(temp_filename), "expected #{temp_filename} to exist")
      assert_equal('/tmp/uploads/abc-123-test_image.png', photo[:url])
    end
  end
end
