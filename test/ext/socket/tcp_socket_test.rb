require "test_helper"

class TCPSocketTest < ActiveSupport::TestCase
  test "doesn't raise when forwarding kwargs" do
    assert_nothing_raised do
      socket = TCPSocket.new 'localhost', 6379
      socket.write_nonblock "forbidden request!", exception: false
    end
  end
end
