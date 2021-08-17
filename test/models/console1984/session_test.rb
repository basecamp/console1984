require "test_helper"

class Console1984::SessionTest < ActiveSupport::TestCase
  test "a session is sensitive if it has any sensitive access" do
    assert_not console1984_sessions(:arithmetic).sensitive?
    assert console1984_sessions(:sensitive_printing).sensitive?
  end
end
