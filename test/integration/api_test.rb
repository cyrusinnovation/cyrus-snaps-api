require 'test_helper'

module CyrusSnaps
  class APITest < Test::Unit::TestCase
    BASE_URL = 'http://localhost:3000'

    let(:db) do
      Sequel.connect('sqlite://db/test.db').tap do |db|
        Sequel.extension :migration
        Sequel::Migrator.check_current(db, 'db/migrate')
      end
    end

    setup do
      db[:photos].delete
      db[:photos] << {
        :uuid         => 'abc-123',
        :content_type => 'image/png',
        :file_size    => 100,
        :filename     => 'test.png',
        :created_at   => Time.now,
        :updated_at   => Time.now,
        :url          => '/uploads'
      }
    end

    test "get all photos" do
      resp = JSON.parse(`curl --silent #{BASE_URL}/photos`).first
      assert_equal('abc-123', resp['uuid'])
    end

    test "get photo by uuid" do
      resp = JSON.parse(`curl --silent #{BASE_URL}/photos/abc-123`)
      assert_equal('abc-123', resp['uuid'])
    end

    test "upload photo" do
      filename = File.join(TEST_DATA_DIR, 'test_image.png')

      resp = `curl -i --silent\
        -F photo[latitude]=1.234\
        -F photo[longitude]=2.345\
        -F 'photo[image]=@#{filename};type=image/png'\
        #{BASE_URL}/photos`

      assert(resp.include?("201 Created"),
        "expected response to include 201 Created but was #{resp}")

      assert_equal(2, db[:photos].count)
    end
  end
end
