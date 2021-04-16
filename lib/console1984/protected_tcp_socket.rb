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
      protected_addresses&.include?(ComparableAddress.new(remote_address))
    end

    def protected_addresses
      Console1984.currently_protected_urls&.collect do |url|
        host, port = host_and_port_from(url)
        Array(Addrinfo.getaddrinfo(host, port)).collect { |addrinfo| ComparableAddress.new(addrinfo) }
      end&.flatten
    end

    def host_and_port_from(url)
      URI(url).then do |parsed_uri|
        if parsed_uri.host
          [parsed_uri.host, parsed_uri.port]
        else
          host_and_port_from_invalid_uri(url)
        end
      end
    rescue URI::InvalidURIError
      host_and_port_from_invalid_uri(url)
    end

    def host_and_port_from_invalid_uri(url)
      host, _, port = url.rpartition(':')
      [host, port]
    end

    ComparableAddress = Struct.new(:ip, :port) do
      def initialize(addrinfo)
        @ip, @port = addrinfo.ip_address, addrinfo.ip_port
      end
    end
end
