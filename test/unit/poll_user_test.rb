require File.dirname(__FILE__) + '/../test_helper'

class PollUserTest < Test::Unit::TestCase
  fixtures :polls, :choices, :users

  def test_author
    # check admins have access
    [@starwars, @caffeine].each { |p| [@rick, @casey].map { |a| assert_can_edit_poll p, a } }
    assert_can_edit_poll @starwars, @dan
    assert_not_edit_poll @caffeine, @dan
  end
  
  # makes sure a user can edit a poll and ALL its choices
  def assert_can_edit_poll(poll, user)
    assert user.can_edit?(poll)
    poll.choices.each { |c| assert user.can_edit?(c) }
  end
  
  def assert_not_edit_poll(poll, user)
    assert !user.can_edit?(poll)
    poll.choices.each { |c| assert !user.can_edit?(c) }
  end
end
