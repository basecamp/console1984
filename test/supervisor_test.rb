require "test_helper"

class IncinerationTest < ActiveSupport::TestCase
  setup do
    @supervisor = Console1984::Supervisor.new
  end

  test "raises error when allow_empty_username is false and no username is provided" do
    original, Console1984.config.ask_for_username_if_empty = Console1984.config.ask_for_username_if_empty, false
    Console1984.username_resolver.username = ""

    assert_raises Console1984::Errors::MissingUsername do
      @supervisor.current_username
    end
  ensure
    Console1984.config.ask_for_username_if_empty = original
  end

  test "asks for username allow_empty_username is true and no username is provided" do
    original, Console1984.config.ask_for_username_if_empty = Console1984.config.ask_for_username_if_empty, true
    Console1984.username_resolver.username = ""

    type_when_prompted "Jorge M." do
      assert_equal "Jorge M.", @supervisor.current_username
    end
  ensure
    Console1984.config.ask_for_username_if_empty = original
  end

  test "can start a session if user_authentication is callable" do
    original, Console1984.config.user_authentication = Console1984.config.user_authentication, ->(username) { true }
    Console1984.username_resolver.username = "jorge"

    assert_nothing_raised do
      type_when_prompted "No reason" do
        @supervisor.start
      end
    end
  ensure
    Console1984.config.user_authentication = original
  end

  test "cannot start a session if user_authentication is callable and raises an exception" do
    original, Console1984.config.user_authentication = Console1984.config.user_authentication, ->(username) { raise "Authentication failed!" }
    Console1984.username_resolver.username = "jorge"

    e = assert_raises RuntimeError do
      @supervisor.start
    end
    assert_equal "Authentication failed!", e.message
  ensure
    Console1984.config.user_authentication = original
  end
end
