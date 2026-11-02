require "test_helper"

class QueryAuditorTest < ActiveSupport::TestCase
  setup do
    @auditor = Console1984::QueryAuditor.new
    Console1984.username_resolver.username = "jorge"
    @console_reason = ENV.delete("CONSOLE_REASON")
  end

  teardown do
    @console_reason.nil? ? ENV.delete("CONSOLE_REASON") : ENV["CONSOLE_REASON"] = @console_reason
  end

  test "records a session with rails query reason when no agent detected" do
    with_env "CLAUDECODE" => nil, "CODEX_THREAD_ID" => nil do
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
    with_env "CLAUDECODE" => "1" do
      simulate_query_notification "Account.count"
    end

    assert_equal "rails query (via Claude Code)", Console1984::Session.last.reason
  end

  test "appends CONSOLE_REASON to the reason" do
    with_env "CLAUDECODE" => "1", "CONSOLE_REASON" => "https://app.basecamp.com/1/buckets/2/card_tables/cards/3" do
      simulate_query_notification "Account.count"
    end

    assert_equal "rails query (via Claude Code): https://app.basecamp.com/1/buckets/2/card_tables/cards/3", Console1984::Session.last.reason
  end

  test "appends CONSOLE_REASON when no agent is detected" do
    with_env "CLAUDECODE" => nil, "CODEX_THREAD_ID" => nil, "CONSOLE_REASON" => "https://github.com/basecamp/bc3/issues/1" do
      simulate_query_notification "Account.count"
    end

    assert_equal "rails query: https://github.com/basecamp/bc3/issues/1", Console1984::Session.last.reason
  end

  test "keeps the plain reason when CONSOLE_REASON is blank" do
    with_env "CLAUDECODE" => "1", "CONSOLE_REASON" => " \t\n " do
      simulate_query_notification "Account.count"
    end

    assert_equal "rails query (via Claude Code)", Console1984::Session.last.reason
  end

  test "flattens CONSOLE_REASON to one line of plain text" do
    with_env "CLAUDECODE" => nil, "CODEX_THREAD_ID" => nil, "CONSOLE_REASON" => "card 42\r\n\e[31mfake\u202Eevil <img src=x onerror=alert(1)>" do
      simulate_query_notification "Account.count"
    end

    assert_equal "rails query: card 42 [31mfake evil img src=x onerror=alert(1)", Console1984::Session.last.reason
  end

  test "drops bytes that aren't valid UTF-8 from CONSOLE_REASON" do
    with_env "CLAUDECODE" => nil, "CODEX_THREAD_ID" => nil, "CONSOLE_REASON" => "card \xFF42".b do
      simulate_query_notification "Account.count"
    end

    assert_equal "rails query: card 42", Console1984::Session.last.reason
  end

  test "caps the length of CONSOLE_REASON" do
    with_env "CLAUDECODE" => nil, "CODEX_THREAD_ID" => nil, "CONSOLE_REASON" => "https://example.com/" + "a" * 1_000 do
      simulate_query_notification "Account.count"
    end

    reason = Console1984::Session.last.reason
    assert_equal "rails query: ".length + Console1984::QueryAuditor::REASON_LENGTH_LIMIT, reason.length
    assert reason.end_with?("…")
  end

  test "records the session under unknown when the username resolves blank" do
    Console1984.username_resolver.username = ""

    simulate_query_notification "Account.count"

    assert_equal "unknown", Console1984::Session.last.user.username
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
