$LOAD_PATH << File.join(File.dirname(__FILE__),"..","..","lib")
$LOAD_PATH << File.join(File.dirname(__FILE__),"..","..","spec")
$LOAD_PATH << File.join(File.dirname(__FILE__),"..","..","spec","models")
require 'active_support'
require 'active_support/dependencies'
require 'active_record'
require 'action_controller'
require 'change_logger'

require 'factory_girl'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'test.db',
  :pool => 5,
  :timeout => 5000
)

require 'factories'