require File.dirname(__FILE__) + '/../test_helper'
require 'tags_controller'

# Re-raise errors caught by the controller.
class TagsController; def rescue_action(e) raise e end; end

class TagsControllerTest < Test::Unit::TestCase
  fixtures :users, :polls, :tags, :polls_tags
  
  def setup
    @controller = TagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = @casey
  end

  def test_routes
    opt = {:controller => 'tags', :action => 'search'}
    assert_generates 'tags/movies/culture', opt.merge(:tags => ['movies', 'culture'])
    assert_generates 'tags/movies', opt.merge(:tags => ['movies'])
  end

  def test_tag
    xhr :post, :tag, :id => @starwars.id, :tag => @movies
    assert_response :success
    assert assigns(:tag).valid?
    assert_tag :tag => 'li', :descendant => { :content => 'movies'}
  end
  
  def test_new_tag
    xhr :post, :tag, :id => @starwars.id, :tag => { :tag => "scifi" }
    assert_response :success
    assert assigns(:tag).valid?
    assert_tag :tag => 'li', :descendant => { :content => 'scifi'}
  end
  
  def test_untag
    xhr :post, :untag, :id => @starwars.id, :tag => @movies.tag
    assert_response :success
    assert !@starwars.tags.include?(@movies)
  end
  
  def test_search
    get :search, :tags => ["food", "drinks"]
    assert_response :success
    assert assigns(:polls)
    assert assigns(:polls).size == 1
  end
end
