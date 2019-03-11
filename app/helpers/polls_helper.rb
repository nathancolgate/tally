module PollsHelper
  def create_poll_form_tag
    start_form_tag({}, {:class => 'fm-poll'})
  end
  
  def edit_poll_form_tag(poll)
    start_form_tag({:id => poll}, {:class => 'fm-poll'} )
  end
  
  def choice_form_remote_tag
    form_remote_tag(:url => {:controller => 'choices', :action => 'create', :poll_id => @poll.id},
      :update => 'choices', :position => :bottom, :complete => 'Choices.complete_add(request)')
  end

  def reply_to_poll_remote_link(poll, choice)
    link_to_remote('+', {:url => {:controller => 'reply', :action => 'create'},
      :with => "'reply[poll_id]=#{poll.id}&reply[choice_id]=#{choice.id}'",
      :complete => 'Reply.create_complete(request)', :update => 'choices'},
      {:class => 'add_link'})
  end
  
  def link_to_remove_choice(choice)
    link_to_remote('X', {:url => {:controller => 'choices', :action => 'destroy', :id => choice.id},
        :complete => "Choices.complete_destroy(request, #{choice.id})"},
        {:class => 'remove_link'})
  end

  def link_to_untag(options = {})
    link_to_remote('X', {:url => {:controller => 'tags', :action => 'untag', :id => options[:id], 
      :tag => options[:tag].tag }, :complete => "Tags.complete_untag(request, #{options[:tag].id})"}, 
      {:class => 'remove_link'})
  end
end
