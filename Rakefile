$LOAD_PATH << File.join(File.dirname(__FILE__), 'features', 'support')
require 'rubygems'
require 'rake'
require 'echoe'
require 'env'

Echoe.new('change_logger', '0.0.2') do |p|
  p.description = "A gem for tracking what changes and who did it"
  p.url = "http://github.com/danengle/awesome_tables"
  p.author = "Dan Engle"
  p.email = "engle.68 @nospam@ gmail.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

namespace :db do
  desc "Migrate the test sqlite3 database"
  task(:migrate) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("spec/migrate")
  end
end