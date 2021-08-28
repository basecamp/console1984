require "test_helper"

class TamperingProtectionTest < ActiveSupport::TestCase
  setup do
    @console = SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason")
  end

  teardown do
    @console.stop
  end

  CASES_PATH = Console1984::Engine.root.join("test", "tampering_cases")

  Dir.glob(File.join(CASES_PATH, "**/*.rb")) do |file_path|
    relative_path = Pathname.new(file_path).relative_path_from CASES_PATH
    test "tampering case #{relative_path}" do
      source = File.read(file_path)

      assert_forbidden_command_attempted source
    end
  end

  private
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
