class InitTestDb < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :persistence_token
      t.timestamps
    end
    create_table :permissions do |t|
      t.string :name
    end
    create_table :permissions_users, :id => false do |t|
      t.integer :permission_id, :user_id, :null => false
    end
    create_table :change_logs do |t|
      t.integer :item_id, :null => false
      t.string :item_type, :null => false
      t.string :attribute_name, :old_value, :new_value
      t.string :changed_by, :null => false
      t.datetime :created_at
    end
    add_index :change_logs, [:item_type, :item_id]
    add_index :change_logs, [:changed_by, :created_at]
  end
  
  def self.down
    drop_table :users
    drop_table :permissions
    drop_table :permissions_users
    drop_table :change_logs
  end
end