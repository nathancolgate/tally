require_dependency "login_system"

class ApplicationController < ActionController::Base
  include LoginSystem
  model :user, :admin, :visitor
  helper_method :loggedin?, :admin?, :visitor?

  protected
  
  def rescue_action_in_public(exception) 
    case exception 
      when ActiveRecord::RecordNotFound, ActionController::UnknownAction 
        render_file "#{RAILS_ROOT}/public/404.html", "404 Not Found" 
      else 
        render_file "#{RAILS_ROOT}/public/500.html", "500 Error" 
        SystemNotifier.deliver_exception_notification( 
          self, request, exception) 
    end 
  end  

  def render_error_on(object)
    return render(:partial => 'shared/error', :object => object, :status => '500 Error')
  end
  
  def ajax_required
    return redirect_to(:controller => 'polls', :action => 'list') unless @request.xhr? and @request.post?
    return false unless login_required
  end

  def get_paging_params!
    @limit = 20
    @page = @params[:page] ? @params[:page][4..-1].to_i : 1
    @offset = (@page-1) * @limit
  end
end