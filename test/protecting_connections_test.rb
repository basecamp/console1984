require "test_helper"

class EncryptionTest < ActiveSupport::TestCase
  SERVER_PORT = 9097

  setup do
    @console = SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason", capture_log_trails: false)

    Console1984.protected_urls = ["localhost:#{39201}"]
  end

  teardown do
    @console.stop
  end

  test "can't connect to protected connections by default" do
    @console.execute <<~RUBY
      socket = TCPSocket.new 'localhost', 39201
      socket.puts "forbidden request!"
    RUBY

    assert_includes @console.output, "127.0.0.1:39201"
    assert_includes @console.output, "connections are protected"
  end

  test "won't interfere with non protected connections" do
    assert_raises Errno::ECONNREFUSED do
      @console.execute <<~RUBY
        socket = TCPSocket.new 'localhost', 12345
        socket.puts "allowed request!"
      RUBY
    end
  end

  test "works when URLs include the user/password" do
    Console1984.protected_urls = ["http://elastic:changeme@localhost:39201"]

    @console.execute <<~RUBY
      socket = TCPSocket.new 'localhost', 39201
      socket.puts "forbidden request!"
    RUBY

    assert_includes @console.output, "127.0.0.1:39201"
  end
end
