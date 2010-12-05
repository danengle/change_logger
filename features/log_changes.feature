Feature: create a change log
	As a user
	I want to record changes to an object
	So that I can track and revert changes if needed
	
	Scenario: create an object
		Given I am identified as "dan"
		And User is an ActiveRecord model
		And it is using acts_as_change_logger
		When I initialize a new user
		And I set the name to "bob"
		And I save the user
		Then there should be a valid change_log record created for name
		And there should not be a change_log record for any ignored attributes

	Scenario: add an has_and_belongs_to_many association to an object
		Given I am identified as "dan"
		And user is an ActiveRecord object
		And it is using acts_as_change_logger
		And it has_and_belongs_to_many permissions
		And user does not have the permission "admin"
		When I add that permission to user
		Then there should be a valid association added change_log record created
		
	Scenario: remove a has_and_belongs_to_many association from an object
		Given I am identified as "dan"
		And user is an ActiveRecord object
		And it is using acts_as_change_logger
		And it has_and_belongs_to_many permissions
		And user has the permission "admin"
		When I remove that permission from user
		Then there should be a valid association removal change_log record created