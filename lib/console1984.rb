require 'console1984/engine'

require 'colorized_string'

module Console1984
  extend ActiveSupport::Autoload

  autoload :AuditTrail
  autoload :AuditTrailSerializer
  autoload :CommandsSniffer
  autoload :Messages
  autoload :SupervisedConsole
  autoload :Supervisor

  mattr_accessor :audit_logger

  mattr_accessor :supervisor
  mattr_accessor :protected_environments

  class << self
    def running_protected_environment?
      protected_environments.collect(&:to_sym).include?(Rails.env.to_sym)
    end
  end
end
