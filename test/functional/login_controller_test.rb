require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Set salt to 'change-me' because thats what the fixtures assume. 
User.salt = 'change-me'

# Raise errors beyond the default web-based presentation
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  
  fixtures :users
  
  def setup
    @controller = LoginController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
  end
  
  def test_routing
    opt = {:controller => 'login'}
    assert_generates 'login', opt.merge(:action => 'login')
    assert_generates 'signup', opt.merge(:action => 'signup')
    assert_generates 'logout', opt.merge(:action => 'logout')
    opt.merge! :action => 'show'
    assert_generates 'user', opt
    assert_generates 'user/dan', opt.merge(:login => 'dan')
  end
  
  def test_invalid_user
    redirect_opt = {:controller => 'polls', :action => 'list'}
    [nil, 'asdfasdf'].each do |login|
      get :show, :login => login
      assert_redirected_to redirect_opt
    end
  end
  
  def test_show_user
    get :show, :login => 'casey'
    assert_response :success
    assert_equal @casey, assigns(:user)
  end
  
  def test_auth_bob_xhr
    xhr :post, :login, :user_login => "bob", :user_password => "test"
    assert_response :success
    assert session[:user]
    assert_equal @bob, @response.session[:user]
  end

  def test_invalid_auth_bob_xhr
    xhr :post, :login, :user_login => "bob", :user_password => "asdfasdfsadfadsf"
    assert_response :error
    assert_tag :content => /Login unsuccessful/
    assert session[:user].nil?
  end

  def test_auth_bob
    @request.session[:return_to] = "/bogus/location"

    post :login, :user_login => "bob", :user_password => "test"
    assert session[:user]
    assert_equal @bob, @response.session[:user]
    
    assert_redirect_url "http://localhost/bogus/location"
  end
  
  def test_signup
    @request.session[:return_to] = "/bogus/location"

    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "newpassword" }
    assert_session_has :user
    
    assert_redirect_url "http://localhost/bogus/location"
  end

  def test_bad_signup
    @request.session[:return_to] = "/bogus/location"

    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "wrong" }
    assert_invalid_column_on_record "user", :password
    assert_success
    
    post :signup, :user => { :login => "yo", :password => "newpassword", :password_confirmation => "newpassword" }
    assert_invalid_column_on_record "user", :login
    assert_success

    post :signup, :user => { :login => "yo", :password => "newpassword", :password_confirmation => "wrong" }
    assert_invalid_column_on_record "user", [:login, :password]
    assert_success
  end

  def test_invalid_login
    post :login, :user_login => "bob", :user_password => "not_correct"
     
    assert_session_has_no :user
    
    assert_template_has "login"
  end
  
  def test_login_logoff

    post :login, :user_login => "bob", :user_password => "test"
    assert_session_has :user

    get :logout
    assert_session_has_no :user

  end
  
  def test_xhr_login_logoff
    xhr :post, :login, :user_login => "bob", :user_password => "test"
    assert_session_has :user
    
    xhr :post, :logout
    assert_session_has_no :user
  end
  
end
