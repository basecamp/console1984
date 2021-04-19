require 'irb'

module Console1984
  class Engine < ::Rails::Engine
    isolate_namespace Console1984

    config.console1984 = ActiveSupport::OrderedOptions.new
    config.console1984.protected_environments ||= %i[ production ]
    config.console1984.protected_urls ||= []

    console do
      Console1984.install_support(config.console1984)
      Console1984.supervisor.start if Console1984.running_protected_environment?

      class OpenSSL::SSL::SSLSocket
        # Make it serve remote address as TCPSocket so that our extension works for it
        def remote_address
          Addrinfo.getaddrinfo(hostname, 443).first
        end
      end
    end
  end
end
