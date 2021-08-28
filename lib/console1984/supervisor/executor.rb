module Console1984::Supervisor::Executor
  extend ActiveSupport::Concern

  include Console1984::Freezeable

  def execute_supervised(commands, &block)
    run_system_command { session_logger.before_executing commands }
    validate_commands(commands)
    execute(&block)
  rescue Console1984::Errors::ForbiddenCommand, Console1984::Errors::ForbiddenCodeManipulation, FrozenError
    flag_forbidden(commands)
  rescue FrozenError
    flag_forbidden(commands)
  ensure
    run_system_command { session_logger.after_executing commands }
  end

  def execute(&block)
    run_user_command do
      with_encryption_mode(&block)
    end
  end

  def executing_user_command?
    @executing_user_command
  end

  private
    def flag_forbidden(commands)
      puts "Forbidden command attempted: #{commands.join("\n")}"
      run_system_command { session_logger.suspicious_commands_attempted commands }
      nil
    end

    def run_user_command(&block)
      run_command true, &block
    end

    def run_system_command(&block)
      run_command false, &block
    end

    def validate_commands(commands)
      if Array(commands).find { |command| forbidden_command?(command) }
        raise Console1984::Errors::ForbiddenCommand
      end
    end

    def forbidden_command?(command)
      command =~ /Console1984|console_1984|(class|module)\s+ActiveRecord::/
    end

    def run_command(run_by_user, &block)
      original_value = @executing_user_command
      @executing_user_command = run_by_user
      block.call
    ensure
      @executing_user_command = original_value
    end
end
