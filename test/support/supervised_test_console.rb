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
    console_json = JSON.parse(last_json_entry)["console"]
    audit_trail_args = console_json.slice("session_id", "user", "commands", "sensitive")

    audit_trail_args["access_reason"] = Console1984::AccessReason.new.tap do |access_reason|
      access_reason.for_session = console_json.dig("access_reason", "for_session")
      access_reason.for_commands = console_json.dig("access_reason", "for_commands")
      access_reason.for_sensitive_access = console_json.dig("access_reason", "for_sensitive_access")
    end

    Console1984::AuditTrail.new(**audit_trail_args.symbolize_keys)
  end

  private
    def simulate_evaluation(statement)
      simulated_console.instance_eval(statement)
    rescue NoMethodError
      eval(statement)
    end

    def start_supervisor(reason)
      type_when_prompted reason do
        @supervisor.start
      end
    end

    def simulated_console
      @simulated_console ||= SimulatedConsole.new(@supervisor)
    end

    class SimulatedConsole
      include Console1984::Commands

      attr_reader :supervisor

      def initialize(supervisor)
        @supervisor = supervisor
      end
    end
end
