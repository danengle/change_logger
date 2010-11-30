%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end

module ChangeLogger
  def self.whodunnit
    change_logger_store[:whodunnit]
  end
  
  def self.whodunnit=(value)
    change_logger_store[:whodunnit] = value
  end
  
  private
  
  # who knows about threads? why is this done this way?
  def self.change_logger_store
    Thread.current[:change_logger] ||= {}
  end
end

require 'app/models/change_log'
require 'change_logger/whodunnit'
require 'change_logger/acts_as_change_logger'

# if defined?(::Rails::Railtie)
  # require 'change_logger/railtie'
# end