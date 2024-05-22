require "active_support/all"

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

  def exit_irb
    stop
    IRB.CurrentContext.exit
  end

  def current_username
    @current_username ||= username_resolver.current.presence || handle_empty_username
  end

  private
    def require_dependencies
      Kernel.silence_warnings do
        require 'parser/current'
      end
      require 'rainbow'

      # Explicit lazy loading because it depends on +parser+, which we want to only load
      # in console sessions.
      require_relative "./command_validator/.command_parser"

      # This solves a weird class loading error where ActiveRecord dosn't resolve +Relation+ properly.
      # See https://github.com/basecamp/console1984/issues/29
      #
      # TODO: This is a temporary fix. Need to figure out why/when this happens.
      require "active_record/relation"
    end

    def start_session
      session_logger.start_session current_username, ask_for_session_reason
    end

    def stop_session
      session_logger.finish_session
    end

    def handle_empty_username
      if Console1984.config.ask_for_username_if_empty
        ask_for_value "Please, enter your name:"
      else
        raise Console1984::Errors::MissingUsername
      end
    end
end
