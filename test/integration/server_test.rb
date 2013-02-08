require 'test_helper'
require 'rack/test'
require 'support/rack_test_assertions'

require 'cyrus_snaps'

module CyrusSnaps
  class ServerTest < Test::Unit::TestCase
    include Rack::Test::Methods
    include Rack::Test::Assertions

    setup do
      DB[:photos].delete
      DB[:photos] << {
        :uuid => 'abc-123',
        :content_type => 'image/png',
        :file_size => 100,
        :filename => 'test.png',
        :created_at => Time.new(2013, 1, 27, 17, 46, 1),
        :updated_at => Time.new(2013, 1, 27, 17, 46, 1),
        :url => '/uploads'
      }
    end

    test "GET /photos" do
      get '/photos'
      assert_response :ok
      assert_content_type :json
      assert_body_contains('[{"uuid":"abc-123","content_type":"image/png","file_size":100,"filename":"test.png","latitude":0.0,"longitude":0.0,"created_at":"2013-01-27T17:46:01-05:00","updated_at":"2013-01-27T17:46:01-05:00","url":"/uploads"}]')
    end

    test "GET /photos/:uuid" do
      get '/photos/abc-123'
      assert_response :ok
      assert_content_type :json
      assert_body_contains('{"uuid":"abc-123","content_type":"image/png","file_size":100,"filename":"test.png","latitude":0.0,"longitude":0.0,"created_at":"2013-01-27T17:46:01-05:00","updated_at":"2013-01-27T17:46:01-05:00","url":"/uploads"}')
    end

    test "successful POST /photos" do
      DB[:photos].delete
      filename = File.join(TEST_DATA_DIR, 'test_image.png')
      image = Rack::Test::UploadedFile.new(filename, 'image/png')

      post '/photos', :photo => {
        :latitude => 1.234,
        :longitude => 2.345,
        :image => image
      }

      assert_response :created
      assert_content_type :json
      assert_equal(1, DB[:photos].count)
    end

    private

    def app
      CyrusSnaps::Server
    end
  end
end
