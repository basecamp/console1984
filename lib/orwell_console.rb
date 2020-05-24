require 'orwell_console/engine'

require 'rainbow'
require 'rainbow/refinement'

module OrwellConsole
  extend ActiveSupport::Autoload

  autoload :AuditTrail
  autoload :AuditTrailSerializer
  autoload :CommandsSniffer
  autoload :Messages
  autoload :SupervisedConsole
  autoload :BigBrother

  mattr_accessor :audit_logger

  mattr_accessor :big_brother
  mattr_accessor :protected_environments

  class << self
    def running_protected_environment?
      protected_environments.collect(&:to_sym).include?(Rails.env.to_sym)
    end
  end
end
