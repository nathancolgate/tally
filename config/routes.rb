ActionController::Routing::Routes.draw do |map|
  # reply
  map.connect 	'reply', 
  				:controller => 'reply', 
  				:action => 'create'
  
  # choices
  map.connect 	'poll/:poll_id/choice/:id/:action', 
  				:controller => 'choices', :action => 'edit',
    			:requirements => { :id => /\d+/, :action => /[a-z]+/ }

  map.connect 	'poll/:poll_id/choice/:action', 
  				:controller => 'choices', 
  				:action => 'create',
    			:requirements => { :action => /[a-z]+/ }

  # tags
  map.connect 	'poll/:id/tag', 
  				:controller => 'tags',
  				:action => 'tag'
  				
  map.connect 	'poll/:id/untag/:tag', 
  				:controller => 'tags', 
  				:action => 'untag'
  				
  map.connect 	'tags/*tags', 
  				:controller => 'tags', 
  				:action => 'search'

  # polls
  map.connect '/rapidfire', :controller => 'polls', :action => 'rapid'
  map.connect 'poll/:id/:action', :controller => 'polls', :action => 'show'
  map.connect 'polls/:page', :controller => 'polls', :action => 'list', :page => 'page1',
    :requirements => { :page => /page\d+/ }
  map.connect 'polls/:action', :controller => 'polls', :action => 'list'

  # xml
  map.connect 'xml/tags/*tags', :controller => 'xml', :action => 'tags'
  
  # login
  map.connect 'user/:login', :controller => 'login', :action => 'show', :login => nil
  map.connect 'login', :controller => 'login', :action => 'login'
  map.connect 'signup', :controller => 'login', :action => 'signup'
  map.connect 'logout', :controller => 'login', :action => 'logout'
  
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect '', :controller => 'polls', :action => 'list'
end
