require 'rails/console/app'

# Entry point to the system. In charge of installing everything
# and starting and stopping sessions.
class Console1984::Supervisor
  include Console1984::Freezeable, Console1984::InputOutput

  delegate :username_resolver, :session_logger, :shield, to: Console1984

  # Installs the console protections.
  #
  # See Console1984::Shield
  def install
    require_dependencies
    shield.install
  end

  # Starts a console session.
  #
  # This will enable protected mode and log the new session in the configured
  # {session logger}[rdoc-ref:Console1984::SessionsLogger::Database].
  def start
    shield.enable_protected_mode(silent: true)
    show_welcome_message
    start_session
  end

  # Stops a console session
  def stop
    stop_session
  end

  private
    def require_dependencies
      Kernel.silence_warnings do
        require 'parser/current'
      end
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
