module Console1984::Supervisor::Accesses
  include Console1984::Messages

  PROTECTED_ACCESS = Protected.new
  UNPROTECTED_ACCESS = Unprotected.new

  def enable_access_to_encrypted_content(silent: false)
    run_system_command do
      show_warning Console1984.enter_unprotected_encryption_mode_warning if !silent && protected_mode?
      justification = ask_for_value "\nBefore you can access personal information, you need to ask for and get explicit consent from the user(s). #{current_username}, where can we find this consent (a URL would be great)?"
      session_logger.start_sensitive_access justification
      nil
    end
  ensure
    @access = UNPROTECTED_ACCESS
    nil
  end

  def disable_access_to_encrypted_content(silent: false)
    run_system_command do
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
end
