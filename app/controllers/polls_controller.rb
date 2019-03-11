class PollsController < ApplicationController
  before_filter :login_required
  before_filter :get_paging_params!, :only => :list

  def list
    @poll_pages = Paginator.new self, Poll.count, @limit, @page
    @polls = Poll.find :all, :limit => @poll_pages.items_per_page, :offset => @offset
  end

  def show(check_replied = true)
    @poll, @partial = Poll.find(@params[:id], :include => :author), 'choices'
    @partial = 'replied' if check_replied and @session[:user] and @session[:user].replied_to?(@poll)
  end
  
  def stats
    show(false)
    @partial = 'stats'
    render :action => 'show'
  end

  def create
    @poll = Poll.new(@params[:poll])
    @poll.author = @session[:user]
    
    if @request.post? and @poll.save
      flash['notice'] = 'Poll was successfully created.'
      redirect_to :action => 'edit', :id => @poll.id
    end
  end

  def edit
    @choice = @poll.clone.choices.build
    if @request.post? and @poll.update_attributes(@params[:poll])
      flash['notice'] = 'Poll was successfully updated.'
      redirect_to :action => 'edit', :id => @poll.id
    end
  end

  def destroy
    @poll.destroy
    redirect_to :action => 'list'
  end
  
  def rapid
    @poll = Poll.find_first_user_has_not_taken(@session[:user])
  end
  
  def rapid_get
    @poll = Poll.find_first_user_has_not_taken(@session[:user])
#    render :partial => "rapid_poll", :locals => { :poll => @poll }
    if @poll
      render_partial "rapid_poll", @poll
    else
      render_text "No more!"
    end
  end

  protected
  # don't protect list/show
  def protect?(action)
    !['list', 'show', 'stats'].include?(action)
  end

  def authorize?(user, action)
    return false unless visitor?
    ["create","rapid","rapid_get"].include?(action) or authorize_edit_and_destroy?(user)
  end

  def authorize_edit_and_destroy?(user)
    return true if (result = (@poll = Poll.find(@params[:id])) and user.can_edit?(@poll))
    flash['error'] = @poll ? 
      "You do not have access to this poll." :
      "This poll does not exist"
    false
  end
end
