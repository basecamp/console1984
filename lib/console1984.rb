require 'console1984/engine'

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Console1984
  include Messages

  mattr_reader :supervisor, default: Supervisor.new
  mattr_reader :config, default: Config.new

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
