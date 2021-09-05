# Supervise execution of console commands:
#
# * It will {validate commands}[rdoc-ref:Console1984::CommandValidator] before running
#   them.
# * It will execute the commands in {protected mode}[rdoc-ref:Console1984::Shield#with_protected_mode]
#   if needed.
# * It will log the command execution, and flag suspicious attempts and forbidden commands
#   appropriately.
class Console1984::CommandExecutor
  include Console1984::Freezeable

  delegate :username_resolver, :session_logger, :shield, to: Console1984

  # Logs and validates +commands+, and executes the passed block in a protected environment.
  #
  # Suspicious commands will be executed but flagged as suspicious. Forbidden commands will
  # be prevented and flagged too.
  def execute(commands, &block)
    run_as_system { session_logger.before_executing commands }
    validate_command commands
    execute_in_protected_mode(&block)
  rescue Console1984::Errors::ForbiddenCommand, FrozenError
    flag_suspicious(commands)
  rescue Console1984::Errors::SuspiciousCommand
    flag_suspicious(commands)
    execute_in_protected_mode(&block)
  rescue FrozenError
    flag_suspicious(commands)
  ensure
    run_as_system { session_logger.after_executing commands }
  end

  # Executes the passed block in protected mode.
  #
  # See Console1984::Shield::Modes.
  def execute_in_protected_mode(&block)
    run_as_user do
      shield.with_protected_mode(&block)
    end
  end

  # Executes the passed block as a user.
  #
  # While the block is being executed, #executing_user_command? will return true.
  # This method helps implementing certain protection mechanisms that should only act with
  # user commands.
  def run_as_user(&block)
    run_command true, &block
  end

  # Executes the passed block as the system.
  #
  # While the block is being executed, #executing_user_command? will return false.
  def run_as_system(&block)
    run_command false, &block
  end

  # Returns whether the system is currently executing a user command.
  def executing_user_command?
    @executing_user_command
  end

  # Validates the command.
  #
  # See Console1984::CommandValidator.
  def validate_command(command)
    command_validator.validate(command)
  end

  private

    def command_validator
      @command_validator ||= build_command_validator
    end

    def build_command_validator
      Console1984::CommandValidator.from_config(Console1984.protections_config.static_validations)
    end

    def flag_suspicious(commands)
      puts "Forbidden command attempted: #{commands.join("\n")}"
      run_as_system { session_logger.suspicious_commands_attempted commands }
      nil
    end

    def run_command(run_by_user, &block)
      original_value = @executing_user_command
      @executing_user_command = run_by_user
      block.call
    ensure
      @executing_user_command = original_value
    end
end
