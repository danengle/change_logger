module ChangeLogHelper
  # there has to be a better way to do this...
  def change_log_whodunnit(change_log)
    user = User.find_by_id(change_log.changed_by.try(:to_i))
    if user.blank?
      user = User.find_by_login(change_log.changed_by)
    end
    if user.nil?
      change_log.changed_by
    else
      link_to user.full_name, user
    end
  end
  
  def change_log_item(change_log)
    begin
      klass = change_log.item_type.constantize
      item = klass.find(change_log.item_id)      
      link_to "#{klass} #{item.id}", send("edit_admin_#{klass.to_s.downcase}_path", item)
    rescue
      "#{change_log.item_type} #{change_log.item_id}"
    end
  end
end