require "test_helper"

class CommandTest < ActiveSupport::TestCase
  test "a command is sensitive if it has any sensitive access" do
    assert_not console1984_commands(:arithmetic_1).sensitive?
    assert console1984_commands(:sensitive_1).sensitive?
  end
end
