require 'test_helper'
require 'cyrus_snaps/photo_query'

module CyrusSnaps
  class PhotoQueryTest < Test::Unit::TestCase
    DB = Sequel.sqlite.tap do |db|
      Sequel.extension :migration
      Sequel::Migrator.run(db, 'db/migrate')
      puts '<= in memory test database created'
    end

    DB[:photos] << {
      :uuid         => 'abc-123',
      :content_type => 'image/png',
      :file_size    => 100,
      :filename     => 'test.png',
      :created_at   => Time.now,
      :updated_at   => Time.now,
      :url          => '/uploads'
    }

    let(:query) { PhotoQuery.new(DB[:photos]) }

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
