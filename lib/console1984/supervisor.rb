require 'colorized_string'
require 'rails/console/app'

# Protects console sessions and executes code in supervised mode.
class Console1984::Supervisor
  include Accesses, Console1984::Freezeable, Executor, InputOutput, Protector

  def install
    extend_protected_systems
    freeze_all
  end

  # Starts a console session extending IRB and several systems to inject
  # the protection logic, and notifies the session logger to record the
  # session.
  def start
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

    def freeze_all
      eager_load_all_classes
      Console1984.config.freeze unless Console1984.config.test_mode
      Console1984::Freezeable.freeze_all
    end

    def eager_load_all_classes
      Rails.application.eager_load! unless Rails.application.config.eager_load
      Console1984.class_loader.eager_load
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

    include Console1984::Freezeable
end
