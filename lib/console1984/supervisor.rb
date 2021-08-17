require 'colorized_string'
require 'rails/console/app'

class Console1984::Supervisor
  include Accesses, InputOutput, Executor

  attr_reader :access_reason, :logger, :session_id
  delegate :session_logger, :username_resolver, to: Console1984

  def initialize(logger: Console1984.audit_logger)
    @logger = logger
    disable_access_to_encrypted_content(silent: true)
    @access_reason = Console1984::AccessReason.new
  end

  def start
    show_production_data_warning
    show_commands

    extend_irb

    session_logger.start_session current_username, ask_for_session_reason
  end

  def stop
    session_logger.finish_session
  end

  private
    def current_username
      username_resolver.current
    end

    def show_production_data_warning
      show_warning Console1984.production_data_warning
    end

    def extend_irb
      IRB::WorkSpace.prepend(Console1984::CommandsSniffer)
      IRB::Context.prepend(Console1984::ProtectedContext)
      Rails::ConsoleMethods.include(Console1984::Commands)
    end

    def ask_for_session_reason
      ask_for_value("#{current_username}, why are you using this console today?")
    end

    def show_commands
      puts COMMANDS_HELP
    end
end
