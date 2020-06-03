module Console1984::Commands
  def decrypt!
    supervisor.enable_access_to_encrypted_content
  end

  def encrypt!
    supervisor.disable_access_to_encrypted_content
  end

  def log(new_reason)
    supervisor.access_reason.for_commands = new_reason
  end

  def consent(new_consent)
    supervisor.access_reason.for_sensitive_access = new_consent
  end

  private
    def supervisor
      Console1984.supervisor
    end
end
