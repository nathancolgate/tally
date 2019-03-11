require File.dirname(__FILE__) + '/../test_helper'
require 'xml_controller'

# Re-raise errors caught by the controller.
class XmlController; def rescue_action(e) raise e end; end

class XmlControllerTest < Test::Unit::TestCase
  fixtures :users, :polls, :tags, :polls_tags, :choices, :replies
  
  def setup
    @controller = XmlController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_user
    get :user, :id => "casey"
    assert_template "poll"
    assert assigns(:polls)
    assert_equal 1, assigns(:polls).size
    assert assigns["feed"]
  end
  
  def test_all
    get :all
    assert_template "poll"
    assert assigns(:polls)
    assert_equal 2, assigns(:polls).size
    assert assigns["feed"]
  end
  
  def test_tags
    get :tags, :tags => ["movies"]
    assert_template "poll"
    assert assigns(:polls)
    assert_equal 1, assigns(:polls).size
    assert_equal @starwars, assigns(:polls).first
    assert assigns["feed"]

    get :tags, :tags => ["culture"]
    assert_template "poll"
    assert assigns(:polls)
    assert_equal 2, assigns(:polls).size
    assert assigns["feed"]
  end
  
  def test_poll_replies
    get :poll_replies, :id => @starwars.id
    assert_template "reply"
    assert assigns(:replies)
    assert_equal 2, assigns(:replies).length
    assert assigns["feed"]
  end
end
