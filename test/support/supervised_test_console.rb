# A console you can use to test the system
class SupervisedTestConsole
  include IoStreamTestHelper
  include Minitest::Assertions

  def initialize(reason: "No reason", user: "Not set")
    @string_io = StringIO.new
    @supervisor = Console1984::Supervisor.new
    Console1984.supervisor = @supervisor

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
