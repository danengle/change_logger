class ChangeLog < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  validates_presence_of :item_id, :item_type, :attribute_name
  
  def value
    # TODO find out if this is the best way to loan an attribute that may
    # or may not be yaml
    begin
      YAML.load(self.new_value)
    rescue
      self.new_value
    end
  end
end