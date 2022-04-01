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
end
