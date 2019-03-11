require File.dirname(__FILE__) + '/../test_helper'

class ReplyTest < Test::Unit::TestCase
  fixtures :users, :polls, :choices, :replies, :users_friends

  def test_no_ballot_stuffing
    @reply = Reply.new
    @reply.poll = @starwars
    @reply.user = @rick
    @reply.choice = @sw_4
    
    assert !@reply.valid?
    assert_not_nil @reply.errors["poll_id"]
    
    @reply.poll = @caffeine
    @reply.choice = @cf_1
    
    assert @reply.valid?
  end

  def test_incorrect_choice
    @reply = Reply.new :poll => @caffeine, :choice => @sw_1, :user => @rick
    assert !@reply.valid?
    assert_not_nil @reply.errors[:base]
  end

  def test_reply_count
    assert_equal 2, @starwars.replies.count
    assert_equal 1, @caffeine.replies.count
  end

  def test_stats
    stats = Choice.stats_by_poll(@starwars)
    assert_equal 6, stats.length
    assert_equal 0, stats[0].total
    assert_equal 1, stats[1].total
    assert_equal 0, stats[2].total
    assert_equal 0, stats[3].total
    assert_equal 1, stats[4].total
    assert_equal 0, stats[5].total
  end

  def test_stats_after_add
    Reply.create :poll => @starwars, :user => @dan, :choice => @sw_1 # ha ha! dan liked jar jar!
    stats = Choice.stats_by_poll(@starwars)
    assert_equal 6, stats.length
    assert_equal 1, stats[0].total
    assert_equal 1, stats[1].total
    assert_equal 0, stats[2].total
    assert_equal 0, stats[3].total
    assert_equal 1, stats[4].total
    assert_equal 0, stats[5].total
  end

  def test_replies_by_user
    ricks_replies = Reply.find_by_user(@rick)
    assert_equal 1, ricks_replies.length
    assert_equal @rick_likes_episode_2.id, ricks_replies.first.id
    assert_equal @rick.login, ricks_replies.first.user_login
  end

  def test_replies_by_friend
    ricks_friends_replies = Reply.find_by_friends_of(@rick)
    assert_equal 1, ricks_friends_replies.length
    assert_equal @casey_likes_episode_5.id, ricks_friends_replies.first.id
    assert_equal @casey.login, ricks_friends_replies.first.user_login
  end
end
