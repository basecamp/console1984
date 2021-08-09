module Console1984::Supervisor::Accesses
  include Console1984::Messages

  def enable_access_to_encrypted_content(silent: false)
    show_warning ENTER_UNPROTECTED_ENCRYPTION_MODE_WARNING if !silent && protected_mode?
    justification = ask_for_value "\nBefore you can access personal information, you need to ask for and get explicit consent from the user(s). #{current_username}, where can we find this consent (a URL would be great)?"
    session_logger.start_sensitive_access justification
  ensure
    @access = Unprotected.new
    nil
  end

  def disable_access_to_encrypted_content(silent: false)
    show_warning ENTER_PROTECTED_MODE_WARNING if !silent && unprotected_mode?
    session_logger.end_sensitive_access
  ensure
    @access = Protected.new
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
