class LoginController < ApplicationController
  def show
    unless @user = User.find_by_login(@params[:login])
      flash['error'] = "'#{@params[:login]}' is an invalid user."
      return redirect_to(:controller => 'polls', :action => 'list')
    end
  end
  
  def login
    return unless @request.post?
    @session[:user] = User.authenticate(@params[:user_login], @params[:user_password])
    msg_successful = "Login successful"
    msg_unsuccessful = "Login unsuccessful. Please check that you entered the right username and password and then try again. If you're not registered yet, <a href=\"/signup\">sign up</a>."
    msg = @session[:user] ? msg_successful : msg_unsuccessful
    if @request.xhr?
      opt = {:text => msg}
      opt[:status] = '500 Error' unless @session[:user]
      render opt
    else
      if @session[:user]
        flash['notice']  = msg
        redirect_back_or_default
      else
        flash.now['notice']  = msg
        @login = @params[:user_login]
      end
    end
  end
  
  def signup
    @user = Visitor.new(@params[:user])
    @user.password = @params[:user][:password] if @params[:user]
    if @request.post? and @user.save
      @session[:user] = User.authenticate(@user.login, @params[:user][:password])
      flash['notice']  = "Welcome to tally, #{@user.login}!"
      redirect_back_or_default
    end      
  end  
  
  def logout
    @session[:user] = nil
    if @request.xhr?
      render :text => "Logged out."
    else
      redirect_back_or_default
    end
  end
end
