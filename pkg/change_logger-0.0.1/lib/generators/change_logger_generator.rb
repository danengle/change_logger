class ChangeLoggerGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)
  
  desc "Create the change_logs migration file"
  def copy_migration
    copy_file "create_change_logs.rb", "db/migrate/#{Time.now.strftime("%Y%m%d%S")}_create_change_logs.rb"
  end
end