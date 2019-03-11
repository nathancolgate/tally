# Used only for ajax create/edit/destroy methods
# all viewing is done in polls controller
class ReplyController < ApplicationController
  before_filter :ajax_required
  layout nil

  def create
    @reply = Reply.new @params[:reply]
    @reply.user = @session[:user]
    return render_error_on('reply') unless @reply.save
    render :partial => 'polls/replied', :locals => {:poll => @reply.poll, :reply => @reply}
  end
  
  def rapid_create
    @reply = Reply.new @params[:reply]
    @reply.user = @session[:user]
    return render_error_on('reply') unless @reply.save
    render_partial "polls/rapid_results", @reply.poll
  end
  
  protected
  def protect?(action)
    false
  end
end