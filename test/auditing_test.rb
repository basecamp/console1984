require "test_helper"

class AuditingTest < ActiveSupport::TestCase
  setup do
    @console = SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason")
  end

  teardown do
    @console.stop
  end

  test "executing commands show the output" do
    @console.execute <<~RUBY
      puts "Result is \#{1+1}"
    RUBY

    assert @console.output.include?("Result is 2")
  end

  test "starting a console creates a session" do
    assert_difference -> { Console1984::Session.count }, +1 do
      SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason")
    end

    session = Console1984::Session.last
    assert "Some very good reason", session.reason
  end

  test "executing commands tracks their execution" do
    assert_audit_trail commands: ["puts 1+1", "puts 2+2"] do
      @console.execute "puts 1+1"
      @console.execute "puts 2+2"
    end

    assert_includes @console.output, "2"
    assert_includes @console.output, "4"
  end

  test "commands in protected mode are not flagged as sensitive" do
    @console.execute "puts Person.last.name"

    assert_not Console1984::Command.last.sensitive?
  end

  test "commands in unprotected mode are justified and flagged as sensitive" do
    assert_difference -> { Console1984::SensitiveAccess.count }, +1 do
      type_when_prompted "I need to fix encoding issue with Message 123456" do
        @console.execute "decrypt!"
      end
    end

    assert_audit_trail commands: ["puts Person.last.name"] do
      @console.execute "puts Person.last.name"
    end

    sensitive_access = Console1984::SensitiveAccess.last
    assert_equal "I need to fix encoding issue with Message 123456", sensitive_access.justification

    last_command = Console1984::Command.last
    assert last_command.sensitive?
    assert_equal sensitive_access, last_command.sensitive_access
  end

  test "a tamper attempt does not mark following legit commands as sensitive" do
    @console.execute "IRB"
    @console.execute "2+2"

    assert_not Console1984::Command.last.sensitive?
  end

  test "in unprotected mode, a tamper attempt does not mark following legit commands as suspicious" do
    @console.execute "1+1"

    type_when_prompted "Checking for inconsistencies..." do
      @console.execute "decrypt!"
    end

    @console.execute "1+1"
    untampered_sensitive_access_id = Console1984::Command.last.sensitive_access_id

    @console.execute "IRB"

    @console.execute "2+2"

    assert Console1984::Command.last.sensitive?
    assert_equal Console1984::Command.last.sensitive_access_id, untampered_sensitive_access_id

    assert Console1984::Command.last.sensitive_access.justification == "Checking for inconsistencies..."
  end

  test "in unprotected mode, a tamper attempt still marks following unlegit commands as suspicious, but assigned to a different sensitive access" do
    @console.execute "1+1"

    type_when_prompted "Checking for inconsistencies..." do
      @console.execute "decrypt!"
    end

    @console.execute "2+2"

    @console.execute "IRB"
    tampered_sensitive_access_id = Console1984::Command.last.sensitive_access_id

    @console.execute "Console1984"

    assert Console1984::Command.last.sensitive?
    assert_not Console1984::Command.last.sensitive_access_id == tampered_sensitive_access_id

    assert Console1984::Command.last.sensitive_access.justification == "Suspicious commands attempted"
  end
end
