require File.dirname(__FILE__) + '/../test_helper'
require 'polls_controller'

# Re-raise errors caught by the controller.
class PollsController; def rescue_action(e) raise e end; end

class PollsControllerTest < Test::Unit::TestCase
  fixtures :polls, :users

  def setup
    @controller = PollsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = @casey
  end

  def test_routing
    options = {:controller => 'polls'}
    assert_generates 'rapidfire', options.merge(:action => 'rapid')
    assert_generates 'polls', options.merge(:action => 'list', :page => 'page1')
    assert_generates 'polls/page2', options.merge(:action => 'list', :page => 'page2')
    options.merge!(:action => 'show', :id => '1')
    assert_generates 'poll/1', options
    assert_generates 'poll/1/edit', options.merge(:action => 'edit')
  end

  def test_list
    get :list
    assert_response :success
    assert_rendered_file 'list'
    assert_template_has 'polls'
  end
  
  def test_list_with_no_replies
    Reply.destroy_all
    get :list
    assert_response :success
    assert_rendered_file 'list'
    assert_template_has 'polls'
  end

  def test_list_with_no_tags
    Tag.destroy_all
    get :list
    assert_response :success
    assert_rendered_file 'list'
    assert_template_has 'polls'
  end

  def test_show
    get :show, 'id' => 1
    assert_rendered_file 'show'
    assert_template_has 'poll'
    assert_valid_record 'poll'
    
    @request.session[:user] = nil
    get :show, 'id' => 1
    assert_rendered_file 'show'
    assert_template_has 'poll'
    assert_valid_record 'poll'
  end

  def test_stats
    get :stats, 'id' => 1
    assert_rendered_file 'show'
    assert_template_has 'poll'
    assert_valid_record 'poll'
  end

  def test_new
    get :create
    assert_rendered_file 'create'
    assert_template_has 'poll'
  end

  def test_create
    num_polls = Poll.find_all.size

    post :create, 'poll' => { :title => 'PC or Mac?', :body => 'The question of the century!!!' }

    assert_redirected_to :action => 'edit', :id => 3

    assert_equal num_polls + 1, Poll.find_all.size
  end

  def test_bad_create
    num_polls = Poll.find_all.size

    post :create, 'poll' => { :body => 'The question of the century!!!' }
    assert_response :success
    assert assigns(:poll).errors.on(:title)

    assert_equal num_polls, Poll.find_all.size
  end

  def test_edit
    get :edit, 'id' => 1
    assert_rendered_file 'edit'
    assert_template_has 'poll'
    assert_valid_record 'poll'
  end

  def test_update
    post :edit, 'id' => 1
    assert_redirected_to :action => 'edit', :id => 1
  end

  def test_destroy
    assert_not_nil Poll.find(1)

    post :destroy, 'id' => 1
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      poll = Poll.find(1)
    }
  end
end
