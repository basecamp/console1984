require 'console1984/engine'

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Console1984
  mattr_accessor :audit_logger

  mattr_accessor :supervisor
  mattr_accessor :protected_environments
  mattr_accessor :protected_urls

  thread_mattr_accessor :currently_protected_urls

  class << self
    def patch_socket_classes
      socket_classes = [ TCPSocket, OpenSSL::SSL::SSLSocket ]
      if defined?(Redis::Connection)
        socket_classes.push *[ Redis::Connection::TCPSocket, Redis::Connection::SSLSocket ]
      end

      socket_classes.compact.each do |socket_klass|
        socket_klass.prepend Console1984::ProtectedTcpSocket
      end
    end

    def running_protected_environment?
      protected_environments.collect(&:to_sym).include?(Rails.env.to_sym)
    end

    def protecting_connections
      self.currently_protected_urls = protected_urls
      yield
    ensure
      self.currently_protected_urls = []
    end
  end
end
