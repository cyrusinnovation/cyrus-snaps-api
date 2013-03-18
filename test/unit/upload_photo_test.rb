require 'test_helper'
require 'rack/test'

require 'uuid'

require 'cyrus_snaps/photo_validator'
require 'cyrus_snaps/upload_photo'

module CyrusSnaps
  class UploadPhotoTest < Test::Unit::TestCase
    setup do
      File.delete(temp_filename) if File.exists?(temp_filename)
      UUID.any_instance.expects(:generate).returns('abc-123')
      Time.stubs(:now).returns(now)

      @block_called = false
      cmd = UploadPhoto.new(params, album) do
        @block_called = true
      end

      @uuid = cmd.call
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

    test "does not call the error block" do
      refute(@block_called, "did not expect error block to be called")
    end
  end

  class UploadInvalidPhotoTest < Test::Unit::TestCase
    setup do
      File.delete(temp_filename) if File.exists?(temp_filename)
      PhotoValidator.any_instance.expects(:valid?).returns(false)

      @block_called = false
      cmd = UploadPhoto.new(params, album) do
        @block_called = true
      end

      cmd.call
    end

    let(:album) { [] }
    let(:temp_filename) { File.expand_path('../../../tmp/uploads/abc-123-test_image.png', __FILE__) }

    let(:params) { Hash.new }

    test "does not store the photo in the album" do
      assert_equal(0, album.size)
    end

    test "does not store the image on file system" do
      temp_filename = File.expand_path('../../../tmp/uploads/abc-123-test_image.png', __FILE__)

      refute(File.exists?(temp_filename), "did not expect #{temp_filename} to exist")
    end

    test "calls the error block" do
      assert(@block_called, "expected error block to be called")
    end
  end
end
