require "test_helper"

# See application.rb in test/dummy to see the protected urls in tests
class EncryptionTest < ActiveSupport::TestCase
  SERVER_PORT = 9097

  setup do
    @console = SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason")
  end

  teardown do
    @console.stop
  end

  test "can't connect to protected connections by default" do
    assert_raises Console1984::Errors::ProtectedConnection do
      @console.execute <<~RUBY
        socket = TCPSocket.new 'localhost', 6379
        socket.puts "forbidden request!"
      RUBY
    end
  end

  test "won't interfere with non protected connections" do
    assert_raises Errno::ECONNREFUSED do
      @console.execute <<~RUBY
        socket = TCPSocket.new 'localhost', 23
        socket.puts "allowed request!"
      RUBY
    end
  end

  test "works when URLs include the user/password" do
    assert_raises Console1984::Errors::ProtectedConnection do
      @console.execute <<~RUBY
        socket = TCPSocket.new 'localhost', 6379
        socket.puts "forbidden request!"
      RUBY
    end
  end
end
