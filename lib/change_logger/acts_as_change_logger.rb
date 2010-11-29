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
        after_save :record_changes
        after_destroy :record_destroy
      end
    end
    
    module InstanceMethods      
      def record_changes
        attributes.delete_if{|k,v| self.class.ignore.include?(k) }.each do |key, value|
          if send("#{key}_changed?")
            create_change_log(key, send("#{key}_was"), send("#{key}"), ::ChangeLogger.whodunnit.id)
          end
        end
      end
      
      def record_destroy
        attributes.delete_if{|k,v| self.class.ignore.include?(k) }.each do |key, value|
          create_change_log(key, send("#{key}_was"), ACTIONS[:delete], ::ChangeLogger.whodunnit.id)
        end
      end
      
      def record_association(record, action)
        if action == ACTIONS[:delete]
          old_val, new_val = record.id, action
        else
          old_val, new_val = action, record.id
        end
        create_change_log(record.class.to_s, old_val, new_val, ::ChangeLogger.whodunnit.id)
      end
      
      private
      
      def create_change_log(attribute_name, old_val, new_val, whodunnit_id)
        self.change_logs.create!(
          :old_value => old_val,
          :new_value => new_val,
          :attribute_name => attribute_name,
          :changed_by_id => whodunnit_id
        )
      end
    end
  end
end
ActiveRecord::Base.send :include, ChangeLogger::ActsAsChangeLogger

ActiveRecord::Associations::HasAndBelongsToManyAssociation.class_eval do |a|
  def insert_record_with_record_changes(record, force = true, validate = true)
    insert_record_without_record_changes(record, force, validate)
    if @owner.respond_to? :record_association
      @owner.record_association(record, ::ChangeLogger::ActsAsChangeLogger::ACTIONS[:create])
    end
  end
  alias_method_chain :insert_record, :record_changes
  
  def delete_records_with_record_changes(records)
    delete_records_without_record_changes(records)
    if @owner.respond_to? :record_association
      records.each do |record|
        @owner.record_association(record, ChangeLogger::ActsAsChangeLogger::ACTIONS[:delete])
      end
    end
  end
  alias_method_chain :delete_records, :record_changes
end




