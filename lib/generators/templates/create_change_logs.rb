class CreateChangeLogs < ActiveRecord::Migration
  def self.up
    create_table :change_logs do |t|
      t.integer :item_id, :null => false
      t.string :item_type, :null => false
      t.string :attribute_name, :old_value, :new_value
      t.integer :changed_by_id, :null => false
      t.timestamps
    end
    add_index :change_logs, [:item_type, :item_id]
  end

  def self.down
    drop_table :change_logs
  end
end
