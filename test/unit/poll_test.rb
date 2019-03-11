require File.dirname(__FILE__) + '/../test_helper'

class PollTest < Test::Unit::TestCase
  fixtures :users, :polls, :tags, :polls_tags

  def test_find_with_tags
    assert_equal [@caffeine], Poll.find_with_tags("food")
    assert_equal [@caffeine], Poll.find_with_tags("food","drinks")
    assert_equal [@caffeine], Poll.find_with_tags(["food"],"drinks")
  end
  
  def test_find_with_tags_options
    assert_equal [@starwars,@caffeine], Poll.find_with_tags("culture",:order => "updated_at desc")
    assert_equal [@caffeine,@starwars], Poll.find_with_tags("culture",:order => "updated_at")
    assert_equal [@starwars], Poll.find_with_tags("culture",:order => "updated_at desc",:limit => 1)
  end
end
