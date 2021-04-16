module Console1984::ProtectedTcpSocket
  def write(*args)
    protecting do
      super
    end
  end

  def write_nonblock(*args)
    protecting do
      super
    end
  end

  private
    def protecting
      if protected?
        raise Console1984::Errors::ProtectedConnection, remote_address.inspect
      else
        yield
      end
    end

    def protected?
      protected_addresses.include?(ComparableAddress.new(remote_address))
    end

    def protected_addresses
      Console1984.currently_protected_urls&.collect do |url|
        uri = URI(url)
        Array(Addrinfo.getaddrinfo(uri.host, uri.port)).collect { |addrinfo| ComparableAddress.new(addrinfo) }
      end&.flatten
    end

    ComparableAddress = Struct.new(:ip, :port) do
      def initialize(addrinfo)
        @ip, @port = addrinfo.ip_address, addrinfo.ip_port
      end
    end
end
