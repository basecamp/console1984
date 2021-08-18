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

  test "trail-tampering commands will be flagged" do
    assert_forbidden_command_attempted "Console1984::Command.last.destroy"
    assert_forbidden_command_attempted "Console1984::Command.last.delete"
    assert_forbidden_command_attempted "Console1984::Session.destroy_all"
  end

  test "trying to override built-in class methods will be prevented and flagged" do
    assert_forbidden_command_attempted <<~RB
      class Console1984::Supervisor
        def some_evil_method_override(*args)
        end
      end
    RB
  end

  private
    def assert_audit_trail(commands: [])
      assert_difference -> { Console1984::Command.count }, commands.length do
        yield
      end

      Console1984::Command.last(commands.length).each.with_index do |command, index|
        assert_equal commands[index], command.statements
      end
    end

    def assert_forbidden_command_attempted(command)
      @console.execute "puts Person.last.name"

      assert_audit_trail commands: [ command ] do
        assert_difference -> { Console1984::SensitiveAccess.count }, +1 do
          @console.execute command
        end
      end

      assert_includes @console.output, "Forbidden command attempted"
      assert Console1984::Command.last.sensitive?
    end
end
