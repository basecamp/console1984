# Console 1984 operates in two modes:
#
# * Protected: it won't reveal encrypted information, attempt to connect to protected urls will be prevented.
# * Unprotected: it will reveal encrypted information and let all connections go through.
#
# Tampering attempts (such as deleting audit trails) is prevented in both modes.
module Console1984::Shield::Modes
  include Console1984::Messages, Console1984::InputOutput
  include Console1984::Freezeable

  PROTECTED_MODE = Protected.new
  UNPROTECTED_MODE = Unprotected.new

  # Switch to protected mode
  #
  # Pass +silent: true+ to hide an informative message when switching to this mode.
  def enable_unprotected_mode(silent: false)
    command_executor.run_as_system do
      show_warning Console1984.enter_unprotected_encryption_mode_warning if !silent && protected_mode?
      justification = ask_for_value "\nBefore you can access personal information, you need to ask for and get explicit consent from the user(s). #{current_username}, where can we find this consent (a URL would be great)?"
      session_logger.start_sensitive_access justification
      nil
    end
  ensure
    @mode = UNPROTECTED_MODE
    nil
  end

  # Switch to unprotected mode
  #
  # Pass +silent: true+ to hide an informative message when switching to this mode.
  def enable_protected_mode(silent: false)
    command_executor.run_as_system do
      show_warning Console1984.enter_protected_mode_warning if !silent && unprotected_mode?
      session_logger.end_sensitive_access
      nil
    end
  ensure
    @mode = PROTECTED_MODE
    nil
  end

  # Executes the passed block in the configured mode (protected or unprotected).
  def with_protected_mode(&block)
    @mode.execute(&block)
  end

  def unprotected_mode?
    @mode.is_a?(Unprotected)
  end

  def protected_mode?
    !unprotected_mode?
  end

  private
    def current_username
      Console1984.supervisor.current_username
    end
end
