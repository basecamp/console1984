# A console you can use to test the system
class SupervisedTestConsole
  include IoStreamTestHelper
  include Minitest::Assertions

  def initialize(reason: "No reason", user: "Not set", capture_log_trails: true)
    @string_io = StringIO.new
    logger = if capture_log_trails
      ActiveSupport::Logger.new(@string_io)
    else
      ActiveSupport::Logger.new("/dev/null")
    end
    @supervisor = Console1984::Supervisor.new(logger: logger)

    ENV["CONSOLE_USER"] = user

    start_supervisor(reason)
  end

  def stop
    @supervisor.stop
  end

  def execute(statement)
    return_value = nil

    output, error = capture_io do
      @supervisor.execute_supervised [statement] do
        return_value = simulate_evaluation(statement)
      end
    end

    @string_io << output + error

    return_value
  end

  def output
    @string_io.string.strip
  end

  def last_json_entry
    output.split("\n").reverse.find { |line| line =~ /@timestamp/ }
  end

  def last_audit_trail
    Console1984::AuditTrail.new(**JSON.parse(last_json_entry)["console"])
  end

  private
    MAPPED_COMMANDS = {
        decrypt!: "enable_access_to_encrypted_content",
        encrypt!: "disable_access_to_encrypted_content"
    }

    def simulate_evaluation(statement)
      mapped_command = MAPPED_COMMANDS[statement.to_sym]
      if mapped_command && @supervisor.respond_to?(mapped_command)
        @supervisor.send(mapped_command)
      else
        eval(statement)
      end
    end

    def start_supervisor(reason)
      type_when_prompted reason do
        @supervisor.start
      end
    end
end
