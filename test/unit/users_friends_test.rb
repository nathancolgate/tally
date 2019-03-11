require File.dirname(__FILE__) + '/../test_helper'

class UsersFriendsTest < Test::Unit::TestCase
  fixtures :users, :users_friends

  def test_friends
    assert_equal 1, @rick.friends.size
    assert @rick.friend?(@casey)
    assert @dan.friend?(@rick)
    assert_nil @rick.friend?(@dan)
  end

  def test_add_friend
    assert @rick.friends << @dan
    assert_equal 2, @rick.friends(true).size
    assert @rick.friend?(@casey)
    assert @rick.friend?(@dan)
  end
end
