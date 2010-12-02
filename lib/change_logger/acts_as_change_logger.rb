module ChangeLogger
  module ActsAsChangeLogger
    ACTIONS = {
      :create => 'CREATED',
      :delete => 'DELETED'
    }
    def self.included(base)
      base.send :extend, ChangeLogger::ActsAsChangeLogger::ClassMethods
    end
    
    module ClassMethods
      def acts_as_change_logger(options = {})
        send :include, InstanceMethods
        cattr_accessor :ignore
        self.ignore = (options[:ignore] || []).map &:to_s
        self.ignore.push('created_at', 'updated_at')
        
        has_many :change_logs, :as => :item, :order => 'change_logs.created_at desc'
        after_save :record_attribute_updates
        after_destroy :record_object_destruction
        self.reflect_on_all_associations(:has_and_belongs_to_many).each do |reflection|
          if reflection.options.keys.include?(:after_add) || reflection.options.keys.include?(:before_add)
            logger.warn { "WARNING: change_logger adds after_add and after_remove options to has_and_belongs_to_many relationships. You need to combine your current methods with the record_association_* methods in order for change_logger to work correctly." }
          end
          new_options = { :after_add => :record_association_add, :after_remove => :record_association_remove }.merge(reflection.options)
          has_and_belongs_to_many reflection.name.to_sym, new_options
        end
      end
    end
    
    module InstanceMethods
      
      def record_association_add(object)
        record_change(object.class.to_s, ACTIONS[:create], object.id)
      end
      
      def record_association_remove(object)
        record_change(object.class.to_s, object.id, ACTIONS[:delete])
      end
      
      def record_attribute_updates
        self.changes.delete_if { |k,v| self.class.ignore.include?(k) }.each do |key, value|
          record_change(key, value[0], value[1])
        end
      end

      def record_object_destruction
        attributes.each do |key, value|
          record_change(key, old_value(key), ACTIONS[:delete])
        end
      end
      
      private
      
      def old_value(attribute)
        if self.new_record?
          ACTIONS[:create]
        else
          send("#{key}_was")
        end
      end
      
      def record_change(attribute_name, old_val, new_val)
        self.change_logs.create!(
          :attribute_name => attribute_name,
          :old_value => old_val,
          :new_value => new_val,
          :changed_by_id => whodunnit.id
        )
      end
    end
  end
end
ActiveRecord::Base.send :include, ChangeLogger::ActsAsChangeLogger