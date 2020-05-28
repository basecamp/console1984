module Console1984::EncryptionMode
  include Console1984::Messages

  def enable_access_to_encrypted_content
    show_warning ENTER_UNPROTECTED_ENCRYPTION_MODE_WARNING
    @encryption_mode = Unprotected.new
    nil
  end

  def disable_access_to_encrypted_content
    show_warning ENTER_PROTECTED_MODE_WARNING
    @encryption_mode = Protected.new
    nil
  end

  def with_encryption_mode(&block)
    @encryption_mode.execute(&block)
  end
end
