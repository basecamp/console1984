require "orwell_console/engine"

require "rainbow"
require 'rainbow/refinement'

module OrwellConsole
  extend ActiveSupport::Autoload

  autoload :AuditTrail
  autoload :AuditTrailSerializer
  autoload :Commands
  autoload :CommandsSniffer
  autoload :Messages
  autoload :SupervisedConsole
  autoload :UsageSupervisor

  mattr_reader :usage_supervisor, default: UsageSupervisor.new
  mattr_accessor :protected_environents, default: %i[ development production ]

  class << self
    def running_protected_environment?
      protected_environents.collect(&:to_sym).include?(Rails.env.to_sym)
    end
  end
end
