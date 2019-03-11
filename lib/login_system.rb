require_dependency "user"

module LoginSystem 
  
  protected
  
  # overwrite this if you want to restrict access to only a few actions
  # or if you want to check if the user has the correct rights  
  # example:
  #
  #  # only allow nonbobs
  #  def authorize?(user, action)
  #    user.login != "bob"
  #  end
  def authorize?(user, action)
     visitor?
  end
  
  # overwrite this method if you only want to protect certain actions of the controller
  # example:
  # 
  #  # don't protect the login and the about method
  #  def protect?(action)
  #    if ['login', 'about'].include?(action)
  #       return false
  #    else
  #       return true
  #    end
  #  end
  def protect?(action)
    false
  end
   
  # login_required filter. add 
  #
  #   before_filter :login_required
  #
  # if the controller should be under any rights management. 
  # for finer access control you can overwrite
  #   
  #   def authorize?(user)
  # 
  def login_required
    # always store location, so if someone logs in we always know where they came from
    store_location
    
    return true unless protect?(action_name)
    return true if @session[:user] and authorize?(@session[:user], action_name)
  
    # call overwriteable reaction to unauthorized access
    flash['error'] = 'Please login' unless flash['error']
    access_denied
    return false 
  end

  # overwrite if you want to have special behavior in case the user is not authorized
  # to access the current operation. 
  # the default action is to redirect to the login screen
  # example use :
  # a popup window might just close itself for instance
  def access_denied
    redirect_to :controller=>"/login", :action =>"login"
  end  
  
  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    @session[:return_to] = @request.request_uri
  end

  # move to the last store_location call or to the passed default one
  def redirect_back_or_default(default = nil)
    default = {:controller => 'polls', :action => 'list', :id => nil} if default.nil?
    if @session[:return_to].nil?
      redirect_to default
    else
      redirect_to_url @session[:return_to]
      @session[:return_to] = nil
    end
  end

  def loggedin?
    !@session[:user].nil?
  end

  def admin?(user = nil)
    loggedin? and @session[:user].admin?
  end

  def visitor?(user = nil)
    loggedin? and @session[:user].visitor?
  end
end