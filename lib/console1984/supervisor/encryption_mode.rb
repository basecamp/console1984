module Console1984::Supervisor::EncryptionMode
  include Console1984::Messages

  def enable_access_to_encrypted_content(silent: false)
    access_reason.for_sensitive_access = ask_for_value "\nBefore you can access personal information, you need to ask for and get explicit consent from the user(s). #{user_name}, where can we find this consent (a URL would be great)?"
    show_warning ENTER_UNPROTECTED_ENCRYPTION_MODE_WARNING if !silent && protected_mode?
    @encryption_mode = Unprotected.new
    nil
  end

  def disable_access_to_encrypted_content(silent: false)
    show_warning ENTER_PROTECTED_MODE_WARNING if !silent && unprotected_mode?
    @encryption_mode = Protected.new
    nil
  end

  def with_encryption_mode(&block)
    @encryption_mode.execute(&block)
  end

  def unprotected_mode?
    @encryption_mode.is_a?(Unprotected)
  end

  def protected_mode?
    !unprotected_mode?
  end
end
