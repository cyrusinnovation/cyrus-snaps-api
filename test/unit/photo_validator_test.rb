require 'test_helper'
require 'validus'
require 'cyrus_snaps/photo_validator'

module CyrusSnaps
  class PhotoValidatorTest < Test::Unit::TestCase
    test "validations pass" do
      validator = PhotoValidator.new({ :title => 'My Photo', :image => stub() })
      assert(validator.valid?)
      assert(validator.errors.empty?)
    end

    test "invalid without title" do
      validator = PhotoValidator.new({ :title => '', :image => stub() })
      refute(validator.valid?)
      assert_equal(["can't be blank"], validator.errors.for(:title).to_a)
    end

    test "invalid without image" do
      validator = PhotoValidator.new({ :title => 'My Photo', :image => nil })
      refute(validator.valid?)
      assert_equal(["is required"], validator.errors.for(:image).to_a)
    end
  end
end
