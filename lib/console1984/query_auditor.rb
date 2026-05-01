class Console1984::QueryAuditor
  mattr_accessor :known_agents, default: {
    "CLAUDECODE"      => "Claude Code",
    "CODEX_THREAD_ID" => "Codex"
  }

  def self.install
    ActiveSupport::Notifications.subscribe("query.rails", new)
  end

  def start(name, id, payload)
    return unless Console1984.running_protected_environment?

    Console1984.session_logger.start_session(resolved_username, session_reason)
    Console1984.session_logger.before_executing([ payload[:expression].to_s ])
  end

  def finish(name, id, payload)
    return unless Console1984.running_protected_environment?

    Console1984.session_logger.finish_session
  end

  private
    def resolved_username
      Console1984.username_resolver.current.presence || "unknown"
    end

    def session_reason
      if agent = detected_agent
        "rails query (via #{agent})"
      else
        "rails query"
      end
    end

    def detected_agent
      known_agents.find { |var, _| ENV[var].present? }&.last
    end
end
