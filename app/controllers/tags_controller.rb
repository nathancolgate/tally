class TagsController < ApplicationController
  before_filter :ajax_required, :only => ["tag", "untag"]
  
  def tag
    @tag = Tag.find_or_create(@params[:tag][:tag])
    unless @tag
      render :status => "500 ERROR"
    else
      @poll.tags << @tag unless @poll.tags.include?(@tag)
      render_partial "tags/tag", @tag, { :poll => @poll }
    end
  end
  
  def untag
    @tag = Tag.find_by_tag(@params[:tag])
    if @tag
      @poll.tags.delete(@tag)
    end
    render :text => "Tag removed."
  end
  
  def search    
    @polls = Poll.find_with_tags(@params[:tags])
  end
  
  protected
  
  def protect?(action)
    ["tag","untag"].include?(action)
  end
  
  def authorize?(user,action)
    return false unless visitor?
    return authorize_tagging?(user) if ["tag","untag"].include?(action)
  end
  
  def authorize_tagging?(user)
    @poll = Poll.find(@params[:id])
    return false unless @poll
    user.can_edit?(@poll)
  end
end
