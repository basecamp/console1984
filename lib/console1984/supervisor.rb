require 'rails/console/app'

# Protects console sessions and executes code in supervised mode.
class Console1984::Supervisor
  include Console1984::Freezeable, Console1984::InputOutput

  delegate :username_resolver, :session_logger, :shield, to: Console1984

  def install
    require_dependencies
    shield.install
  end

  # Starts a console session extending IRB and several systems to inject
  # the protection logic, and notifies the session logger to record the
  # session.
  def start
    shield.enable_protected_mode(silent: true)
    show_welcome_message
    start_session
  end

  def stop
    stop_session
  end

  private
    def require_dependencies
      require 'parser/current'
      require 'colorized_string'
    end

    def start_session
      session_logger.start_session current_username, ask_for_session_reason
    end

    def stop_session
      session_logger.finish_session
    end

    def current_username
      username_resolver.current
    end
end
