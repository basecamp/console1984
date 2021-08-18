require 'colorized_string'
require 'rails/console/app'

class Console1984::Supervisor
  include Accesses, InputOutput, Executor

  attr_reader :session_id

  def start
    Console1984.config.freeze
    disable_access_to_encrypted_content(silent: true)
    show_production_data_warning
    show_commands

    extend_irb

    session_logger.start_session current_username, ask_for_session_reason
  end

  def stop
    session_logger.finish_session
  end

  private
    def session_logger
      Console1984.session_logger
    end

    def current_username
      username_resolver.current
    end

    def username_resolver
      Console1984.username_resolver
    end

    def show_production_data_warning
      show_warning Console1984.production_data_warning
    end

    def extend_irb
      IRB::Context.prepend(Console1984::ProtectedContext)
      Rails::ConsoleMethods.include(Console1984::Commands)
    end

    def ask_for_session_reason
      ask_for_value("#{current_username}, why are you using this console today?")
    end

    def show_commands
      puts COMMANDS_HELP
    end

    include Console1984::FrozenMethods
end
