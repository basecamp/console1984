require 'console1984/engine'

require "zeitwerk"
class_loader = Zeitwerk::Loader.for_gem
class_loader.setup

module Console1984
  include Messages, Freezeable

  mattr_accessor :supervisor, default: Supervisor.new

  mattr_reader :config, default: Config.new

  mattr_accessor :class_loader

  thread_mattr_accessor :currently_protected_urls, default: []

  class << self
    Config::PROPERTIES.each do |property|
      delegate property, to: :config
    end

    def running_protected_environment?
      protected_environments.collect(&:to_sym).include?(Rails.env.to_sym)
    end

    def protecting(&block)
      protecting_connections do
        ActiveRecord::Encryption.protecting_encrypted_data(&block)
      end
    end

    private
      def protecting_connections
        old_currently_protected_urls = self.currently_protected_urls
        self.currently_protected_urls = protected_urls
        yield
      ensure
        self.currently_protected_urls = old_currently_protected_urls
      end
  end
end

Console1984.class_loader = class_loader
