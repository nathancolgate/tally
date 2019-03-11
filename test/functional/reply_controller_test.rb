require File.dirname(__FILE__) + '/../test_helper'
require 'reply_controller'

# Re-raise errors caught by the controller.
class ReplyController; def rescue_action(e) raise e end; end

class ReplyControllerTest < Test::Unit::TestCase
  fixtures :choices, :polls, :users, :replies

  def setup
    @controller = ReplyController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = @rick
  end

  def test_non_ajax
    redirect_options = {:controller => 'polls', :action => 'list'}
    [:create].each do |a|
      get a
      assert_redirected_to redirect_options
      post a
      assert_redirected_to redirect_options
    end
  end

  def test_routing
    assert_generates 'reply', :controller => 'reply', :action => 'create'
  end

  def test_create
    num_choices = Reply.find_all.size

    xhr :post, :create, :reply => { :poll_id => @caffeine.id, :choice_id => @cf_1.id }
    assert_response :success
    assert assigns(:reply)
    assert assigns(:reply).poll
    assert assigns(:reply).user
    assert assigns(:reply).choice
    assert assigns(:reply).valid?

    assert_equal num_choices + 1, Reply.find_all.size
  end

  def test_ballot_stuffing
    num_choices = Reply.find_all.size

    xhr :post, :create, :reply => { :poll_id => @starwars.id, :choice_id => @sw_4.id }
    assert_response :error
    assert assigns(:reply)
    assert assigns(:reply).poll
    assert assigns(:reply).user
    assert assigns(:reply).choice
    assert !assigns(:reply).valid?

    assert_equal num_choices, Reply.find_all.size
  end

  def test_ballot_stuffing
    num_choices = Reply.find_all.size
    xhr :post, :create, :reply => { :poll_id => @caffeine.id, :choice_id => @sw_1.id }
    assert_response :error
    assert assigns(:reply)
    assert assigns(:reply).poll
    assert assigns(:reply).user
    assert assigns(:reply).choice
    assert !assigns(:reply).valid?

    assert_equal num_choices, Reply.find_all.size
  end
end