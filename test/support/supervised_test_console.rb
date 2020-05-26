# A console you can use to test the system
class SupervisedTestConsole
  include IoStreamTestHelper

  def initialize(reason: "No reason", user: "Not set")
    @string_io = StringIO.new
    @logger = ActiveSupport::Logger.new(@string_io)
    @supervisor = Console1984::Supervisor.new(logger: @logger)

    ENV["CONSOLE_USER"] = user

    start_supervisor(reason)
  end

  def stop
    @supervisor.stop
  end

  def execute(statement)
    @supervisor.execute_supervised [ statement ] do
      eval(statement)
    end
  end

  def output
    @string_io.string.strip
  end

  def last_json_entry
    output[/(^.+)\Z/, 0]
  end

  def last_audit_trail
    Console1984::AuditTrail.new(**JSON.parse(last_json_entry)["console"])
  end

  private
    def start_supervisor(reason)
      type_when_prompted reason do
        @supervisor.start
      end
    end
end
