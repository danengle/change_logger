module ChangeLogger
  module ActsAsChangeLogger
    ACTIONS = {
      :create => 'CREATED',
      :update => 'UPDATED',
      :delete => 'DELETED'
    }
    def self.included(base)
      base.send :extend, ChangeLogger::ActsAsChangeLogger::ClassMethods
    end
    
    module ClassMethods
      def acts_as_change_logger(options = {})
        send :include, InstanceMethods
        
        cattr_accessor :ignore, :track_templates
        self.ignore = (options[:ignore] || []).map &:to_s
        self.ignore.push('id', 'revision', 'created_at', 'updated_at')
        self.track_templates = (options[:track_templates] || []).map &:to_s
        
        attr_accessor :template_changed
        after_update :record_template_change
        
        has_many :change_logs, :as => :item, :order => 'change_logs.created_at desc'
        after_create :record_object_creation
        before_update :increment_revision
        after_update :record_attribute_updates
        before_destroy :record_object_destruction
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
      
      def increment_revision
        self.increment(:revision) if self.respond_to?(:revision)
      end
      
      def record_template_change
        self.template_changed = {} if self.template_changed.nil?
        if self.template_changed.values.include?(true)
          self.template_changed.keys.each do |relation|
            record_change("#{relation}_template", ACTIONS[:update], self.send(relation).to_yaml)
          end
        end
      end
      
      def record_association_add(object)
        if self.class.track_templates.include?(object.class.to_s.tableize)
          self.template_changed = {} if self.template_changed.nil?
          self.template_changed[object.class.to_s.tableize.to_sym] = true          
        else
          record_change(object.class.to_s, ACTIONS[:create], object.id) if self.persisted?
        end
      end
      
      def record_association_remove(object)
        if self.class.track_templates.include?(object.class.to_s.tableize)
          self.template_changed = {} if self.template_changed.nil?
          self.template_changed[object.class.to_s.tableize.to_sym] = true          
        else
          record_change(object.class.to_s, object.id, ACTIONS[:delete]) if self.persisted?
        end
      end
      
      def record_object_creation
        attributes.delete_if {|k,v| self.class.ignore.include?(k) }.each do |key, value|
          record_change(key, ACTIONS[:create], value) unless value.blank?
        end        
      end
      
      def record_attribute_updates
        changes_to_track.each do |key, value|
          record_change(key, value[0], value[1])
        end        
      end

      def record_object_destruction
        attributes.each do |key, value|
          record_change(key, value, ACTIONS[:delete])
        end
      end

      def changes_to_track
        (new_record? ? attributes : changes).delete_if {|k,v| self.class.ignore.include?(k) }
      end
      
      private
      
      def record_change(attribute_name, old_val, new_val)        
        change_log = self.change_logs.new(
          :attribute_name => attribute_name,
          :old_value => old_val,
          :new_value => new_val,
          :changed_by => whodunnit
        )
        change_log.revision = self.revision if self.respond_to?(:revision)
        change_log.save
      end
            
    end
  end
end
ActiveRecord::Base.send :include, ChangeLogger::ActsAsChangeLogger