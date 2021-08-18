require 'colorized_string'
require 'rails/console/app'

class Console1984::Supervisor
  include Accesses, InputOutput, Executor, Protector

  attr_reader :session_id

  def start
    Console1984.config.freeze
    extend_protected_systems
    disable_access_to_encrypted_content(silent: true)

    show_welcome_message

    start_session
  end

  def stop
    stop_session
  end

  private
    def start_session
      session_logger.start_session current_username, ask_for_session_reason
    end

    def stop_session
      session_logger.finish_session
    end

    def session_logger
      Console1984.session_logger
    end

    def current_username
      Console1984.username_resolver.current
    end

    def username_resolver
      Console1984.username_resolver
    end

    include Console1984::FrozenMethods
end
