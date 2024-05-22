# The shield implements the protection mechanisms while using the console:
#
# * It extends different systems with console1984 extensions (including IRB itself).
# * It offers an API to the rest of the system to enable and disable protected modes and
#   execute code on the configured mode.
#
# Protection happens at two levels:
#
# * External: preventing users from accessing encrypted data or protected systems while on
#   protected mode.
# * Internal: preventing users from tampering Console 1984 itself.
class Console1984::Shield
  include Modes
  include Console1984::Freezeable

  delegate :username_resolver, :session_logger, :command_executor, to: Console1984

  # Installs the shield by extending several systems and freezing classes and modules
  # that aren't mean to be modified once the console is running.
  def install
    extend_protected_systems
    prevent_invoking_protected_methods

    refrigerator.freeze_all
  end

  private
    def extend_protected_systems
      extend_irb
      extend_core_ruby
      extend_sockets unless Console1984.protected_urls.blank?
      extend_active_record
    end

    def extend_irb
      IRB::Context.prepend(Console1984::Ext::Irb::Context)
      IRB::Command.register :decrypt!, Console1984::Commands::Decrypt
      IRB::Command.register :encrypt!, Console1984::Commands::Encrypt
    end

    def extend_core_ruby
      Object.prepend Console1984::Ext::Core::Object
      Module.prepend Console1984::Ext::Core::Module
      String.prepend Console1984::Ext::Core::String
    end

    def extend_sockets
      socket_classes = [TCPSocket, OpenSSL::SSL::SSLSocket]
      OpenSSL::SSL::SSLSocket.include(SSLSocketRemoteAddress)

      if defined?(Redis::Connection::TCPSocket)
        socket_classes.push(Redis::Connection::TCPSocket)
      end

      if defined?(Redis::Connection::SSLSocket)
        socket_classes.push(Redis::Connection::SSLSocket)
      end

      socket_classes.compact.each do |socket_klass|
        socket_klass.prepend Console1984::Ext::Socket::TcpSocket
        socket_klass.freeze
      end
    end

    ACTIVE_RECORD_CONNECTION_ADAPTERS = %w[ActiveRecord::ConnectionAdapters::Mysql2Adapter ActiveRecord::ConnectionAdapters::PostgreSQLAdapter ActiveRecord::ConnectionAdapters::SQLite3Adapter]

    def extend_active_record
      ACTIVE_RECORD_CONNECTION_ADAPTERS.each do |class_string|
        if Object.const_defined?(class_string)
          klass = class_string.constantize
          klass.prepend(Console1984::Ext::ActiveRecord::ProtectedAuditableTables)
        end
      end
    end

    def prevent_invoking_protected_methods
      MethodInvocationShell.install_for(Console1984.protections_config.forbidden_methods)
    end

    def refrigerator
      @refrigerator ||= Console1984::Refrigerator.new
    end

    module SSLSocketRemoteAddress
      # Serve remote address as TCPSocket so that our extension works with both.
      def remote_address
        Addrinfo.getaddrinfo(hostname, 443).first
      end
    end
end
