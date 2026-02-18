require "test_helper"

class TCPSocketTest < ActiveSupport::TestCase
  setup do
    @server = TCPServer.new("localhost", 6379) rescue nil
  end

  teardown do
    @server&.close
  end

  test "doesn't raise when forwarding kwargs" do
    assert_nothing_raised do
      socket = TCPSocket.new("localhost", 6379)
      socket.write_nonblock "content", exception: false
    end
  end
end
