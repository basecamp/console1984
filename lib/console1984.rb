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

    def install_support(properties)
      config.set properties
      extend_protected_systems
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
      def extend_protected_systems
        extend_active_record
        extend_socket_classes
      end

      def extend_active_record
        %w[ActiveRecord::ConnectionAdapters::Mysql2Adapter ActiveRecord::ConnectionAdapters::PostgreSQLAdapter ActiveRecord::ConnectionAdapters::SQLite3Adapter].each do |class_string|
          if Object.const_defined?(class_string)
            klass = class_string.constantize
            klass.prepend(Console1984::ProtectedAuditableTables)
          end
        end
      end

      def extend_socket_classes
        socket_classes = [TCPSocket, OpenSSL::SSL::SSLSocket]
        if defined?(Redis::Connection)
          socket_classes.push(*[Redis::Connection::TCPSocket, Redis::Connection::SSLSocket])
        end

        socket_classes.compact.each do |socket_klass|
          socket_klass.prepend Console1984::ProtectedTcpSocket
        end
      end

      def protecting_connections
        old_currently_protected_urls = self.currently_protected_urls
        self.currently_protected_urls = protected_urls
        yield
      ensure
        self.currently_protected_urls = old_currently_protected_urls
      end
  end
end
