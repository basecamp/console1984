class Console1984::QueryAuditor
  REASON_ENV_KEY = "CONSOLE_REASON"
  REASON_LENGTH_LIMIT = 255

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
      [ default_reason, given_reason ].compact.join(": ")
    end

    def default_reason
      if agent = detected_agent
        "rails query (via #{agent})"
      else
        "rails query"
      end
    end

    def detected_agent
      known_agents.find { |var, _| ENV[var].present? }&.last
    end

    # The authorization link (card, issue, support conversation) for this query, from CONSOLE_REASON.
    # It is shown in the audit UI, so keep it to one line of plain text: no control or format
    # characters (newlines, bidi overrides), no markup brackets, and a bounded length.
    def given_reason
      ENV.fetch(REASON_ENV_KEY, "").dup.force_encoding(Encoding::UTF_8).scrub("")
        .gsub(/[\p{Cc}\p{Cf}<>]/, " ").squish
        .truncate(REASON_LENGTH_LIMIT, omission: "…")
        .presence
    end
end
