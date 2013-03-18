require 'test_helper'
require 'rack/test'
require 'support/rack_test_assertions'

require 'cyrus_snaps'

module CyrusSnaps
  class ServerTest < Test::Unit::TestCase
    include Rack::Test::Methods
    include Rack::Test::Assertions

    let(:photo) do
      {
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
      PhotoQuery.any_instance.expects(:all).returns([photo])

      get '/photos'

      assert_response :ok
      assert_content_type :json
      assert_body_contains(JSON.generate([photo]))
    end

    test "GET /photos/:uuid" do
      PhotoQuery.any_instance.expects(:by_uuid).with('abc-123').returns(photo)

      get '/photos/abc-123'

      assert_response :ok
      assert_content_type :json
      assert_body_contains(JSON.generate(photo))
    end

    test "successful POST /photos" do
      UploadPhoto.expects(:call)
      post '/photos', :photo => {}

      assert_response :created
      assert_content_type :json
    end

    test "unsuccessful POST /photos" do
      PhotoValidator.any_instance.expects(:valid?).returns(false)
      errors = stub(:full_messages => ["title can't be blank"])
      PhotoValidator.any_instance.expects(:errors).returns(errors)
      post '/photos', :photo => {}

      assert_response :bad_request
      assert_body_contains('{"errors":["title can\'t be blank"]}')
    end

    private

    def app
      CyrusSnaps::Server
    end
  end
end
