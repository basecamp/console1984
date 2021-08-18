module Console1984::Supervisor::Protector
  extend ActiveSupport::Concern

  private
    def extend_protected_systems
      extend_irb
      extend_active_record
      extend_socket_classes
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
end
