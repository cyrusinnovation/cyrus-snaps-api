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
      resp = JSON.parse(`curl --silent #{BASE_URL}/photos`)
      assert_equal(1, resp.count)
      assert_equal('abc-123', resp.first['uuid'])
    end

    test "get photo by uuid" do
      resp = JSON.parse(`curl --silent #{BASE_URL}/photos/abc-123`)
      assert_equal('abc-123', resp['uuid'])
    end

    test "successfully upload photo" do
      filename = File.join(TEST_DATA_DIR, 'test_image.png')

      resp = `curl -i --silent\
        -F photo[title]='Some Photo'\
        -F photo[latitude]=1.234\
        -F photo[longitude]=2.345\
        -F 'photo[image]=@#{filename};type=image/png'\
        #{BASE_URL}/photos`

      assert(resp.include?("201 Created"),
        "expected response to include 201 Created but was #{resp}")

      assert_equal(2, db[:photos].count)

      photo = db[:photos].all.last
      assert_equal('Some Photo', photo[:title])
      assert_equal(1.234, photo[:latitude])
      assert_equal(2.345, photo[:longitude])
      assert_equal('image/png', photo[:content_type])
      assert(photo[:filename].include?('test_image.png'),
             "expected #{photo[:filename]} to include test_image.png")
    end

    test "unsuccessfully upload photo" do
      filename = File.join(TEST_DATA_DIR, 'test_image.png')

      resp = `curl -i --silent\
        -F photo[title]=''\
        -F photo[latitude]=1.234\
        -F photo[longitude]=2.345\
        -F 'photo[image]=@#{filename};type=image/png'\
        #{BASE_URL}/photos`

      assert(resp.include?("400 Bad Request"),
        "expected response to include 400 Bad Request but was #{resp}")

      assert(resp.include?('{"errors":["title can\'t be blank"]}'),
        "expected response to include errors JSON")

      assert_equal(1, db[:photos].count)
    end
  end
end
