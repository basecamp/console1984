# A session logger that saves audit trails in the database.
class Console1984::SessionsLogger::Database
  include Console1984::Freezeable

  attr_reader :current_session, :current_sensitive_access

  def start_session(username, reason)
    silence_logging_and_ensure_connected do
      user = Console1984::User.find_or_create_by!(username: username)
      @current_session = user.sessions.create!(reason: reason)
    end
  end

  def finish_session
    @current_session = nil
    @current_sensitive_access = nil
  end

  def start_sensitive_access(justification)
    silence_logging_and_ensure_connected do
      @current_sensitive_access = current_session.sensitive_accesses.create! justification: justification
    end
  end

  def end_sensitive_access
    @current_sensitive_access = nil
  end

  def before_executing(statements)
    silence_logging_and_ensure_connected do
      @before_commands_count = @current_session.commands.count
      record_statements statements
    end
  end

  def after_executing(statements)
  end

  def suspicious_commands_attempted(statements)
    silence_logging_and_ensure_connected do
      sensitive_access = start_sensitive_access "Suspicious commands attempted"
      Console1984::Command.last.update! sensitive_access: sensitive_access
    end
  end

  private
    def record_statements(statements)
      @current_session.commands.create! statements: Array(statements).join("\n"), sensitive_access: current_sensitive_access
    end

    def silence_logging_and_ensure_connected(&block)
      if Console1984.debug
        ensure_connected(&block)
      else
        Console1984::IncinerationJob.logger.silence do
          Console1984::Base.logger.silence do
            ensure_connected(&block)
          end
        end
      end
    end

    def ensure_connected(&block)
      Console1984::Command.connection.reconnect! unless Console1984::Command.connection.active?
      block.call
    end
end
