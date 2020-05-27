require 'console1984/engine'

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Console1984
  mattr_accessor :audit_logger

  mattr_accessor :supervisor
  mattr_accessor :protected_environments

  class << self
    def running_protected_environment?
      protected_environments.collect(&:to_sym).include?(Rails.env.to_sym)
    end
  end
end
