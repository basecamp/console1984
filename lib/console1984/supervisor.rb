require 'colorized_string'
require 'rails/console/app'

class Console1984::Supervisor
  include EncryptionMode, InputOutput, Console1984::Messages

  attr_reader :access_reason, :logger, :session_id

  def initialize(logger: Console1984.audit_logger)
    @logger = logger
    disable_access_to_encrypted_content(silent: true)
    @access_reason = Console1984::AccessReason.new
  end

  def start
    configure_loggers
    generate_session_id
    show_production_data_warning
    extend_irb
    access_reason.for_session = ask_for_session_reason
    show_commands
  end

  def execute_supervised(commands, &block)
    before_executing commands
    ActiveSupport::Notifications.instrument "console.audit_trail", \
      audit_trail: Console1984::AuditTrail.new(session_id: session_id, user: user, access_reason: access_reason, commands: commands.join("\n"), sensitive: sensitive_access?) do
      execute(&block)
    end
  ensure
    after_executing commands
  end

  def execute(&block)
    with_encryption_mode(&block)
  end

  # Used only for testing purposes
  def stop
    ActiveSupport::Notifications.unsubscribe "console.audit_trail"
  end

  private
    def before_executing(commands)
      # This could be used to record commands *before* they get executed, to prevent hijacking
      # the console auditing system (or, at least, knowing if someone tries)
    end

    def after_executing(commands)
      log_audit_trail
    end

    def configure_loggers
      configure_rails_loggers
      configure_structured_logger
    end

    def configure_rails_loggers
      Rails.application.config.structured_logging.logger = ActiveSupport::Logger.new(structured_logger_string_io)
      ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
      ActiveJob::Base.logger.level = :error
    end

    def structured_logger_string_io
      @structured_logger_io ||= StringIO.new
    end

    def configure_structured_logger
      RailsStructuredLogging::Recorder.instance.attach_to(ActiveRecord::Base.logger)
      @subscription = RailsStructuredLogging::Subscriber.subscribe_to \
        'console.audit_trail',
        logger: Rails.application.config.structured_logging.logger,
        serializer: Console1984::AuditTrailSerializer
    end

    def show_production_data_warning
      show_warning PRODUCTION_DATA_WARNING
    end

    def generate_session_id
      @session_id = SecureRandom.alphanumeric(10)
    end

    def sensitive_access?
      unprotected_mode?
    end

    def extend_irb
      IRB::WorkSpace.prepend(Console1984::CommandsSniffer)
      IRB::Context.prepend(Console1984::ProtectedContext)
      Rails::ConsoleMethods.include(Console1984::Commands)
    end

    def ask_for_session_reason
      ask_for_value("#{user_name}, why are you using this console today?")
    end

    def log_audit_trail
      logger.info read_audit_trail_json
    end

    def read_audit_trail_json
      structured_logger_string_io.string.strip[/(^.+)\Z/, 0] # grab the last line
    end

    def user
      ENV['CONSOLE_USER'] ||= 'Unnamed' if Rails.env.development? || Rails.env.test?
      ENV['CONSOLE_USER'] or raise "$CONSOLE_USER not defined. Can't run console unless identified"
    end

    def user_name
      "#{user&.humanize}"
    end

    def show_commands
      puts COMMANDS_HELP
    end
end
