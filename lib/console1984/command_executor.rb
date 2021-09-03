class Console1984::CommandExecutor
  include Console1984::Freezeable

  delegate :username_resolver, :session_logger, :shield, to: Console1984

  def execute(commands, &block)
    run_as_system { session_logger.before_executing commands }
    validate_command commands
    protecting_encrypted_content(&block)
  rescue Console1984::Errors::ForbiddenCommand, FrozenError
    flag_suspicious(commands)
  rescue Console1984::Errors::SuspiciousCommand
    flag_suspicious(commands)
    protecting_encrypted_content(&block)
  rescue FrozenError
    flag_suspicious(commands)
  ensure
    run_as_system { session_logger.after_executing commands }
  end

  def protecting_encrypted_content(&block)
    run_as_user do
      shield.with_encryption_mode(&block)
    end
  end

  def run_as_user(&block)
    run_command true, &block
  end

  def run_as_system(&block)
    run_command false, &block
  end

  def executing_user_command?
    @executing_user_command
  end

  def validate_command(command)
    command_validator.validate(command)
  end

  private
    COMMAND_VALIDATOR_CONFIG_FILE_PATH = Console1984::Engine.root.join("config/command_protections.yml")

    def command_validator
      @command_validator ||= build_command_validator
    end

    def build_command_validator
      Console1984::CommandValidator.from_config(YAML.safe_load(File.read(COMMAND_VALIDATOR_CONFIG_FILE_PATH)).symbolize_keys)
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
