require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :polls, :tags, :polls_tags

  def test_fix_tag
    assert_equal "sometag", Tag.fix_tag("Some Tag")
    assert_equal "sometag1232xyz", Tag.fix_tag("SomeTag1232!@#!#!xyz")
  end
  
  def test_find_by_tag
    assert_equal @movies, Tag.find_by_tag("MOVIES")
    assert_equal @movies, Tag.find_by_tag("mo!vies")
  end
  
  def test_find_or_create
    assert_equal @movies, Tag.find_or_create("movies")

    tag_count = Tag.count
    @tag = Tag.find_or_create("computers")
    assert !@tag.new_record?
    assert_equal tag_count + 1, Tag.count
  end
end
