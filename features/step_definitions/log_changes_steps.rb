Given /^I am identified as "([^"]*)"$/ do |whodunnit| #"
  (ChangeLogger.whodunnit = whodunnit).should be(whodunnit)
end

Given /^User is an ActiveRecord model$/ do
  User.ancestors.include?(ActiveRecord::Base).should be_true
end

Given /^it is using acts_as_change_logger$/ do
  User.ancestors.include?(ChangeLogger::ActsAsChangeLogger::InstanceMethods).should be_true
end

When /^I initialize a new user$/ do
  @user = User.new
end

When /^I set the name to "([^"]*)"$/ do |name| #"
  @user.name = name
  @user.name.should == name
end

When /^I save the user$/ do
  @user.save
end

Then /^there should be a valid change_log record created for ([^"]*)$/ do |name| #"
  change_log = ChangeLog.where({:item_id => @user.id, :item_type => @user.class.to_s, :attribute_name => name}).first
  change_log.should_not be_blank
  change_log.old_value.should == ChangeLogger::ActsAsChangeLogger::ACTIONS[:create]
  change_log.new_value.should == @user.name
end

Then /^there should not be a change_log record for any ignored attributes$/ do
  change_logs = ChangeLog.where({:item_id => @user.id, :item_type => @user.class.to_s})
  change_logs.size.should == 1
end

Given /^user is an ActiveRecord object$/ do
  @user = Factory.create(:user)
end

Given /^it has_and_belongs_to_many permissions$/ do
  @user.class.reflect_on_all_associations(:has_and_belongs_to_many).any?{|a| a.name == :permissions}
end

Then /^there should be a valid association added change_log record created$/ do
  change_log = ChangeLog.where({:item_id => @user.id, :item_type => @user.class.to_s, :attribute_name => @permission.class.to_s}).first
  change_log.should_not be_blank
  change_log.old_value.should == ChangeLogger::ActsAsChangeLogger::ACTIONS[:create]
  change_log.new_value.should == @permission.id.to_s
end

Then /^there should be a valid association removal change_log record created$/ do
  change_log = ChangeLog.where({:item_id => @user.id, :item_type => @user.class.to_s, :attribute_name => @permission.class.to_s}).last
  change_log.should_not be_blank
  change_log.old_value.should == @permission.id.to_s
  change_log.new_value.should == ChangeLogger::ActsAsChangeLogger::ACTIONS[:delete]
end

Given /^user does not have the permission "([^"]*)"$/ do |name| #"
  @permission = Factory.create(:permission)
  @user.permissions.include?(@permission).should be_false
end

Given /^user has the permission "([^"]*)"$/ do |name| #"
  @permission = Factory.create(:permission)
  @user.permissions << @permission
  @user.permissions.include?(@permission).should be_true
end

When /^I add that permission to user$/ do
  @user.permissions << @permission
  @user.permissions.include?(@permission).should be_true
end

When /^I remove that permission from user$/ do
  @user.permissions.delete(@permission)
  @user.permissions.include?(@permission).should be_false
end
