module Console1984::Supervisor::Executor
  extend ActiveSupport::Concern

  def execute_supervised(commands, &block)
    session_logger.before_executing commands
    execute(commands, &block)
  ensure
    session_logger.after_executing commands
  end

  def execute(commands, &block)
    run_user_command do
      with_encryption_mode(&block)
    end
  rescue Console1984::Errors::ForbiddenCommand
    session_logger.suspicious_commands_attempted commands
  end

  def executing_user_command?
    @executing_user_command
  end

  private
    def run_user_command(&block)
      run_command true, &block
    end

    def run_system_command(&block)
      run_command false, &block
    end

    def run_command(run_by_user, &block)
      original_value = @executing_user_command
      @executing_user_command = run_by_user
      block.call
    ensure
      @executing_user_command = original_value
    end
end
