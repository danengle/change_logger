class User < ActiveRecord::Base
  has_and_belongs_to_many :permissions
  acts_as_change_logger
  validates_uniqueness_of :name
end