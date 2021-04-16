require 'irb'

module Console1984
  class Engine < ::Rails::Engine
    isolate_namespace Console1984

    config.console1984 = ActiveSupport::OrderedOptions.new
    config.console1984.protected_environments ||= %i[ production ]
    config.console1984.protected_urls ||= []

    console do
      Console1984.protected_environments ||= config.console1984.protected_environments
      Console1984.audit_logger = config.console1984.audit_logger || ActiveSupport::Logger.new(STDOUT)
      Console1984.supervisor = Supervisor.new
      Console1984.protected_urls = config.console1984.protected_urls

      Console1984.supervisor.start if Console1984.running_protected_environment?

      class OpenSSL::SSL::SSLSocket
        # Make it serve remote address as TCPSocket so that our extension works for it
        def remote_address
          Addrinfo.getaddrinfo(hostname, 443).first
        end
      end
    end

    initializer "console1984.protected_urls" do
      [TCPSocket, OpenSSL::SSL::SSLSocket].each do |socket_klass|
        socket_klass.include Console1984::ProtectedTcpSocket
      end
    end
  end
end
