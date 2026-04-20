require "test_helper"

class QueryAuditorTest < ActiveSupport::TestCase
  setup do
    @auditor = Console1984::QueryAuditor.new
  end

  test "records a session with rails query reason when no agent detected" do
    with_env "CLAUDECODE" => nil, "CODEX_THREAD_ID" => nil, "QUERY_AGENT" => nil do
      assert_difference -> { Console1984::Session.count }, +1 do
        simulate_query_notification "Account.count"
      end

      assert_equal "rails query", Console1984::Session.last.reason
      assert_equal "jorge", Console1984::Session.last.user.username
    end
  end

  test "records the expression as a command" do
    simulate_query_notification "Account.where(fake: false).count"

    assert_equal "Account.where(fake: false).count", Console1984::Command.last.statements
  end

  test "labels sessions triggered by known agent env vars" do
    with_env "CLAUDECODE" => "1", "QUERY_AGENT" => nil do
      simulate_query_notification "Account.count"
    end

    assert_equal "rails query (via Claude Code)", Console1984::Session.last.reason
  end

  test "QUERY_AGENT override wins over known agent detection" do
    with_env "CLAUDECODE" => "1", "QUERY_AGENT" => "my-bot" do
      simulate_query_notification "Account.count"
    end

    assert_equal "rails query (via my-bot)", Console1984::Session.last.reason
  end

  private
    def simulate_query_notification(expression)
      @auditor.start("query.rails", "id", { expression: expression })
      @auditor.finish("query.rails", "id", { expression: expression })
    end

    def with_env(vars)
      before = vars.keys.index_with { |key| ENV[key] }
      vars.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
      yield
    ensure
      before.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    end
end
