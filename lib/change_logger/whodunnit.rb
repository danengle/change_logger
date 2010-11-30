module ChangeLogger
  module Whodunnit
    
    def self.included(base)
      base.before_filter :set_whodunnit
    end
    
    protected
    
    def whodunnit
      current_user rescue nil
    end
    
    private
    
    def set_whodunnit
      ::ChangeLogger.whodunnit = whodunnit
    end
  end
end
ActionController::Base.send :include, ::ChangeLogger::Whodunnit

Kernel.module_eval do
  def whodunnit
    ::ChangeLogger.whodunnit
  end
end