class XmlController < ApplicationController
  layout nil
  
  def user
    @user = User.find_by_login(@params[:id])
    unless @user
      render_nothing
      return
    end
    @polls = Poll.find_by_author(@user,:limit => 10)
    @feed = {
      :id => "userpolls-#{@user.login}",
      :title => "#{@user.login}'s recent polls at tally!",
      :url => url_for(:controller => "user", :action => @user.login, :only_path => false)
    }
    render_action "poll"
  end
  
  def all
    @polls = Poll.find_recent
    @feed = {
      :id => "allpolls",
      :title => "Recent polls at tally!",
      :url => url_for(:controller => "polls", :action => "list", :only_path => false)
    }
    render_action "poll"
  end
  
  def tags
    tags = @params[:tags].map {|tag| Tag.fix_tag(tag) }
    @polls = Poll.find_with_tags(tags,:limit => 10,:order => "updated_at desc")
    @feed = {
      :id => "tagged-#{tags.join("-")}",
      :title => "Recent #{tags.join("/")} polls at tally!",
      :url => url_for(:controller => "tags", :action => "search", :tags => tags, :only_path => false)
    }
    render_action "poll"
  end
  
  def poll_replies
    @poll = Poll.find(@params[:id])
    unless @poll
      render_nothing
      return
    end

    @replies = Reply.find_by_poll(@poll,{ :limit => 10 })

    @feed = {
      :id => "poll-replies-#{@poll.id}",
      :title => "Replies to #{@poll.title} at tally!",
      :url => url_for(:controller => "polls", :action => "show", :id => @poll.id)
    }
    render_action "reply"
  end
end
