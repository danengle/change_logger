module ChangeLogger
  module ActsAsChangeLogger
    def self.included(base)
      base.send :extend, ChangeLogger::ActsAsChangeLogger::ClassMethods
    end
    
    module ClassMethods
      # def has_many(association_id, options = {}, &extension)
        # puts "!!This is the has many change_logger method"
        # super(association_id, options, &extension)
        # puts "!!this is after"
      # end
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
          create_change_log(key, send("#{key}_was"), "DELETED", ::ChangeLogger.whodunnit.id)
        end
      end
      
      def record_association(record)
        create_change_log(record.class.to_s, 'CREATE', record.id, ::ChangeLogger.whodunnit.id)
      end
      
      def record_association_delete(records)
        records.each_with_index do |record,index|
          create_change_log(record.class.to_s, record.id, 'DELETED', ::ChangeLogger.whodunnit.id)
        end
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
  def insert_with_change_log(record, force = true, validate = true)
    insert_without_change_log(record, force, validate)
    if @owner.respond_to? :record_association
      @owner.record_association(record)
    end
  end
  alias_method :insert_without_change_log, :insert_record
  alias_method :insert_record, :insert_with_change_log
  
  def delete_records_with_change_log(records)
    delete_records_without_change_log(records)
    if @owner.respond_to? :record_association_delete
      @owner.record_association_delete(records)
    end
  end
  alias_method :delete_records_without_change_log, :delete_records
  alias_method :delete_records, :delete_records_with_change_log
end




