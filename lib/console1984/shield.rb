class Console1984::Shield
  include Accesses
  include Console1984::Freezeable

  delegate :username_resolver, :session_logger, :command_executor, to: Console1984

  def install
    extend_protected_systems
    freeze_all
  end

  private
    def extend_protected_systems
      extend_object
      extend_irb
      extend_active_record
      extend_socket_classes
    end

    def extend_object
      Object.prepend Console1984::ProtectedObject
    end

    def extend_irb
      IRB::Context.prepend(Console1984::ProtectedContext)
      Rails::ConsoleMethods.include(Console1984::Commands)
    end

    ACTIVE_RECORD_CONNECTION_ADAPTERS = %w[ActiveRecord::ConnectionAdapters::Mysql2Adapter ActiveRecord::ConnectionAdapters::PostgreSQLAdapter ActiveRecord::ConnectionAdapters::SQLite3Adapter]

    def extend_active_record
      ACTIVE_RECORD_CONNECTION_ADAPTERS.each do |class_string|
        if Object.const_defined?(class_string)
          klass = class_string.constantize
          klass.prepend(Console1984::ProtectedAuditableTables)
          klass.include(Console1984::Freezeable)
        end
      end
    end

    def extend_socket_classes
      socket_classes = [TCPSocket, OpenSSL::SSL::SSLSocket]
      OpenSSL::SSL::SSLSocket.include(SSLSocketRemoteAddress)

      if defined?(Redis::Connection)
        socket_classes.push(*[Redis::Connection::TCPSocket, Redis::Connection::SSLSocket])
      end

      socket_classes.compact.each do |socket_klass|
        socket_klass.prepend Console1984::ProtectedTcpSocket
        socket_klass.freeze
      end
    end

    def freeze_all
      eager_load_all_classes
      Console1984.config.freeze unless Console1984.config.test_mode
      Console1984::Freezeable.freeze_all
    end

    def eager_load_all_classes
      Rails.application.eager_load! unless Rails.application.config.eager_load
      Console1984.class_loader.eager_load
    end

    module SSLSocketRemoteAddress
      # Make it serve remote address as TCPSocket so that our extension works for it
      def remote_address
        Addrinfo.getaddrinfo(hostname, 443).first
      end
    end
end