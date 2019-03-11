require File.dirname(__FILE__) + '/../test_helper'
require 'choices_controller'

# Re-raise errors caught by the controller.
class ChoicesController; def rescue_action(e) raise e end; end

class ChoicesControllerTest < Test::Unit::TestCase
  fixtures :choices, :polls, :users

  def setup
    @controller = ChoicesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = @casey
  end

  def test_non_ajax
    redirect_options = {:controller => 'polls', :action => 'list'}
    [:create, :edit, :destroy].each do |a|
      get a
      assert_redirected_to redirect_options
      post a
      assert_redirected_to redirect_options
    end
  end

  def test_routing
    options = {:controller => 'choices', :action => 'create', :poll_id => @caffeine.id.to_s}
    assert_generates "poll/#{@caffeine.id}/choice", options
    options.merge!(:action => 'edit', :id => '235')
    assert_generates "poll/#{@caffeine.id}/choice/235", options
    assert_generates "poll/#{@caffeine.id}/choice/235/destroy", options.merge(:action => 'destroy')
  end

  def test_create
    num_choices = Choice.find_all.size

    xhr :post, :create, :choice => { :body => 'Starbucks Doubleshot' }, :poll_id => @caffeine.id
    assert_response :success
    assert assigns(:choice).valid?
    assert_tag :tag => 'li', :descendant => { :content => 'Starbucks Doubleshot'}

    assert_equal num_choices + 1, Choice.find_all.size
  end
  
  def test_create_error
    xhr :post, :create, :choice => { }, :poll_id => @caffeine.id
    assert_response :error
    assert !assigns(:choice).valid?
  end

  def test_update
    xhr :post, :edit, :id => @cf_2.id, :choice => { :body => 'Monster Lo Carb', :poll_id => @caffeine.id }
    assert_response :success
    assert assigns(:choice).valid?
    assert_tag :tag => 'li', :descendant => { :content => 'Monster Lo Carb'}
  end

  def test_destroy
    assert_not_nil Choice.find(1)

    xhr :post, :destroy, :id => 1
    assert_response :success

    assert_raise(ActiveRecord::RecordNotFound) {
      choice = Choice.find(1)
    }
  end
end
