require 'console1984/engine'

require "zeitwerk"
class_loader = Zeitwerk::Loader.for_gem
class_loader.setup

# console1984 is an IRB-based Rails console extension that does
# three things:
#
# * Record console sessions with their user, reason and commands.
# * Protect encrypted data by showing the ciphertexts when you visualize it.
# * Protect access to external systems that contain sensitive information (such as Redis or Elasticsearch).
#
#
module Console1984
  include Messages, Freezeable

  mattr_accessor :supervisor, default: Supervisor.new

  mattr_reader :config, default: Config.new

  mattr_accessor :class_loader

  class << self
    Config::PROPERTIES.each do |property|
      delegate property, to: :config
    end

    def running_protected_environment?
      protected_environments.collect(&:to_sym).include?(Rails.env.to_sym)
    end
  end
end

Console1984.class_loader = class_loader
