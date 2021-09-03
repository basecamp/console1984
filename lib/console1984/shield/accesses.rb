module Console1984::Shield::Accesses
  include Console1984::Messages, Console1984::InputOutput, Console1984::Freezeable

  PROTECTED_ACCESS = Protected.new
  UNPROTECTED_ACCESS = Unprotected.new

  def enable_unprotected_mode(silent: false)
    command_executor.run_as_system do
      show_warning Console1984.enter_unprotected_encryption_mode_warning if !silent && protected_mode?
      justification = ask_for_value "\nBefore you can access personal information, you need to ask for and get explicit consent from the user(s). #{current_username}, where can we find this consent (a URL would be great)?"
      session_logger.start_sensitive_access justification
      nil
    end
  ensure
    @access = UNPROTECTED_ACCESS
    nil
  end

  def enable_protected_mode(silent: false)
    command_executor.run_as_system do
      show_warning Console1984.enter_protected_mode_warning if !silent && unprotected_mode?
      session_logger.end_sensitive_access
      nil
    end
  ensure
    @access = PROTECTED_ACCESS
    nil
  end

  def with_encryption_mode(&block)
    @access.execute(&block)
  end

  def unprotected_mode?
    @access.is_a?(Unprotected)
  end

  def protected_mode?
    !unprotected_mode?
  end

  private
    def current_username
      username_resolver.current
    end
end
