require 'console1984/engine'

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Console1984
  include Messages

  mattr_accessor :supervisor
  mattr_accessor :session_logger
  mattr_accessor :username_resolver

  mattr_accessor :protected_environments
  mattr_reader :protected_urls, default: []

  mattr_reader :production_data_warning, default: DEFAULT_PRODUCTION_DATA_WARNING
  mattr_reader :enter_unprotected_encryption_mode_warning, default: DEFAULT_ENTER_UNPROTECTED_ENCRYPTION_MODE_WARNING
  mattr_reader :enter_protected_mode_warning, default: DEFAULT_ENTER_PROTECTED_MODE_WARNING

  mattr_accessor :incinerate, default: true
  mattr_accessor :incinerate_after, default: 30.days
  mattr_accessor :incineration_queue, default: "console1984_incineration"

  mattr_accessor :debug, default: false

  thread_mattr_accessor :currently_protected_urls, default: []

  class << self
    def install_support(config)
      self.protected_environments ||= config.protected_environments
      self.protected_urls.push(*config.protected_urls)
      self.session_logger = config.session_logger || Console1984::SessionsLogger::Database.new
      self.username_resolver = config.username_resolver || Console1984::Username::EnvResolver.new("CONSOLE_USER")

      self.supervisor = Supervisor.new
      self.protected_urls.freeze

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
