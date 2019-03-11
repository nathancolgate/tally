RAILS_ROOT = File.dirname(__FILE__) + "/../"
RAILS_ENV  = ENV['RAILS_ENV'] || 'development'


# Mocks first.
ADDITIONAL_LOAD_PATHS = ["#{RAILS_ROOT}/test/mocks/#{RAILS_ENV}"]

# Then model subdirectories.
ADDITIONAL_LOAD_PATHS.concat(Dir["#{RAILS_ROOT}/app/models/[_a-z]*"])
ADDITIONAL_LOAD_PATHS.concat(Dir["#{RAILS_ROOT}/components/[_a-z]*"])

# Followed by the standard includes.
ADDITIONAL_LOAD_PATHS.concat %w(
  app 
  app/models 
  app/controllers 
  app/helpers 
  app/apis 
  components 
  config 
  lib 
  vendor 
  vendor/rails/railties
  vendor/rails/railties/lib
  vendor/rails/actionpack/lib
  vendor/rails/activesupport/lib
  vendor/rails/activerecord/lib
  vendor/rails/actionmailer/lib
  vendor/rails/actionwebservice/lib
).map { |dir| "#{RAILS_ROOT}/#{dir}" }.select { |dir| File.directory?(dir) }

# Prepend to $LOAD_PATH
ADDITIONAL_LOAD_PATHS.reverse.each { |dir| $:.unshift(dir) if File.directory?(dir) }

# Require Rails libraries.
unless File.directory?("#{RAILS_ROOT}/vendor/rails")
  require 'rubygems' 

  require_gem 'activesupport',    '>= 1.0.4.1380'
  require_gem 'activerecord',     '>= 1.10.1.1380'
  require_gem 'actionpack',       '>= 1.8.1.1380'
  require_gem 'actionmailer',     '>= 0.9.1.1380'
  require_gem 'actionwebservice', '>= 0.7.1.1380'
else
  require 'active_support'
  require 'active_record'
  require 'action_controller'
  require 'action_mailer'
  require 'action_web_service'
end

# Environment-specific configuration.
require_dependency "environments/#{RAILS_ENV}"
ActiveRecord::Base.configurations = File.open("#{RAILS_ROOT}/config/database.yml") { |f| YAML::load(f) }
ActiveRecord::Base.establish_connection


# Configure defaults if the included environment did not.
begin
  RAILS_DEFAULT_LOGGER = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log")
rescue StandardError
  RAILS_DEFAULT_LOGGER = Logger.new(STDERR)
  RAILS_DEFAULT_LOGGER.level = Logger::WARN
  RAILS_DEFAULT_LOGGER.warn(
    "Rails Error: Unable to access log file. Please ensure that log/#{RAILS_ENV}.log exists and is chmod 0666. " +
    "The log level has been raised to WARN and the output directed to STDERR until the problem is fixed."
  )
end

[ActiveRecord, ActionController, ActionMailer].each { |mod| mod::Base.logger ||= RAILS_DEFAULT_LOGGER }
[ActionController, ActionMailer].each { |mod| mod::Base.template_root ||= "#{RAILS_ROOT}/app/views/" }
ActionController::Routing::Routes.reload

Controllers = Dependencies::LoadingModule.root(
  File.join(RAILS_ROOT, 'app', 'controllers'),
  File.join(RAILS_ROOT, 'components')
)

# FUGLY hack to get those *dead sexy* page routes
# /tags/search/blah/page1 
# Ticket #1184 is the patch for this....
ActionView::Helpers::PaginationHelper::DEFAULT_OPTIONS[:link_prefix] = ''
module ActionView::Helpers::PaginationHelper
  def pagination_links(paginator, options={})
    options.merge!(DEFAULT_OPTIONS) {|key, old, new| old}
    
    window_pages = paginator.current.window(options[:window_size]).pages

    return if window_pages.length <= 1 unless
      options[:link_to_current_page]
    
    first, last = paginator.first, paginator.last
    
    returning html = '' do
      if options[:always_show_anchors] and not window_pages[0].first?
        html << link_to(first.number, { options[:name] => "#{options[:link_prefix]}#{first.number}" }.update( options[:params] ))
        html << ' ... ' if window_pages[0].number - first.number > 1
        html << ' '
      end
      
      window_pages.each do |page|
        if paginator.current == page && !options[:link_to_current_page]
          html << page.number.to_s
        else
          html << link_to(page.number, { options[:name] => "#{options[:link_prefix]}#{page.number}" }.update( options[:params] ))
        end
        html << ' '
      end
      
      if options[:always_show_anchors] && !window_pages.last.last?
        html << ' ... ' if last.number - window_pages[-1].number > 1
        html << link_to(last.number, { options[:name] => "#{options[:link_prefix]}#{last.number}" }.update( options[:params]))
      end
    end
  end
end
