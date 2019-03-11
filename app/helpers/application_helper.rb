# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # creates link to single poll
  # options overwrites link_to options
  # except options[:text] which overwrites the link text (defaults to poll.title)
  def link_to_poll(poll, options = {})
    link_to((options.delete(:text) || poll.title), polls_options({:action => 'show', :id => poll.id}, options))
  end
  
  def link_to_polls(text, options = {})
    link_to text, polls_options({}, options)
  end
  
  def link_to_user(user, options = {})
    link_to((options.delete(:text) || user.login), login_options({:login => user.login}, options))
  end

  # takes a string tag or a Tag
  def link_to_tag(tag, combine = true)
    tag = (tag.is_a?(Tag) ? tag.tag : tag).downcase
    if combine
      tags = @params[:tags] || []
      tags << tag unless tags.include?(tag)
    else
      tags = [tag]
    end
    link_to tag, :controller => 'tags', :action => 'search', :tags => tags
  end
  
  # takes a Poll or an array of string tags or Tags
  def link_to_tags(tags, sep = ', ', combine = true)
    (tags.is_a?(Poll) ? tags.tags : tags).collect { |t| link_to_tag(t, combine) }.join(sep)
  end
  
  def login_form_remote_tag
    form_remote_tag :url => { :controller => "login", :action => "login" }, :complete => "Auth.login_complete(request)"
  end

  def link_to_signup
    link_to "Signup", :controller => "login", :action => "signup"
  end

  def link_to_logout
    link_to_remote "Logout", :url => { :controller => "login", :action => "logout" }, :complete => "Auth.logoff_complete(request)"
  end
  
  def link_to_user_feed(user,options={})
    link_to((options.delete(:text) || user.login), :controller => "xml", :action => "user", :id => user.login)
  end
  
  def link_to_all_polls_feed(options={})
    link_to((options.delete(:text) || "All Polls"), :controller => "xml", :action => "all")
  end
  
  def link_to_tag_polls_feed(tags,options={})
    link_to((options.delete(:text) || "Tags: #{tags.join(", ")}"), :controller => "xml", :action => "tags", :tags => tags)
  end
  
  def link_to_poll_replies_feed(poll,options={})
    link_to((options.delete(:text) || poll.title), :controller => "xml", :action => "poll_replies", :id => poll.id)
  end

  def tags_form_remote_tag(options)
    form_remote_tag :url => { :controller => "tags", :action => "tag", :id => options[:poll_id] }, :complete => "Tags.complete_tag(request)", :update => "tags", :position => :bottom
  end
  
  def page_title(in_head = false)
    t = @title || "#{controller.controller_name} :: #{controller.action_name}"
    in_head ? t.gsub(/<(.|\n)*?>/, '') : t
  end
  
  def render_flash
    cls = @flash['error'] ? 'error' : 'notice'
    @flash[cls] ? 
      content_tag('div', @flash[cls], :id => 'flash', :class => cls) : 
      content_tag('div', '', :id => 'flash')
  end

  def paging_links(paginator, previous_label, next_label)
    s = ''
    s << link_to(previous_label, :page => "page#{paginator.current.previous.number}") if paginator.current.previous
    s << link_to(next_label, :page => "page#{paginator.current.next.number}") if paginator.current.next
    s
  end

  private
  # lazy helper, i know!
  def login_options(default_options = {}, override_options = {})
    {:controller => 'login', :action => 'show', :login => nil}.merge(default_options).merge(override_options)
  end
  def polls_options(default_options = {}, override_options = {})
    {:controller => 'polls', :action => 'list', :id => nil}.merge(default_options).merge(override_options)
  end
end
