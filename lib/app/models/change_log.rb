class ChangeLog < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  validates_presence_of :item_id, :item_type, :attribute_name
end