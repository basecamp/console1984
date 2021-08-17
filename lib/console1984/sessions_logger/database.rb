class Console1984::SessionsLogger::Database
  attr_reader :current_session, :current_sensitive_access

  def start_session(username, reason)
    user = Console1984::User.create_or_find_by!(username: username)
    @current_session = user.sessions.create! reason: reason
  end

  def finish_session
    @current_session = nil
    @current_sensitive_access = nil
  end

  def start_sensitive_access(justification)
    @current_sensitive_access = current_session.sensitive_accesses.create! justification: justification
  end

  def end_sensitive_access
    @current_sensitive_access = nil
  end

  def before_executing(statements)
    @before_commands_count = @current_session.commands.count
    record_statements statements
  end

  def after_executing(statements)
  end

  def suspicious_commands_attempted(statements)
    sensitive_access = start_sensitive_access "Suspicious commands attempted"
    Console1984::Command.last.update! sensitive_access: sensitive_access
  end

  private
    def record_statements(statements)
      @current_session.commands.create! statements: Array(statements).join("\n"), sensitive_access: current_sensitive_access
    end
end
