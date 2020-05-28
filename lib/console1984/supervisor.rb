require 'colorized_string'
require 'rails/console/app'

class Console1984::Supervisor
  include Console1984::EncryptionMode, Console1984::Messages

  attr_reader :reason, :logger, :encryption_mode

  def initialize(logger: Console1984.audit_logger)
    @logger = logger
    disable_access_to_encrypted_content(silent: true)
  end

  def start
    configure_loggers
    show_production_data_warning
    extend_irb
    @reason = ask_for_reason
  end

  def execute_supervised(statements, &block)
    before_executing statements
    ActiveSupport::Notifications.instrument "console.audit_trail", \
      audit_trail: Console1984::AuditTrail.new(user: user, reason: reason, statements: statements.join("\n")) do
      execute(&block)
    end
  ensure
    after_executing statements
  end

  def execute(&block)
    with_encryption_mode(&block)
  end

  # Used only for testing purposes
  def stop
    ActiveSupport::Notifications.unsubscribe "console.audit_trail"
  end

  private
    def before_executing(statements)
      # This could be used to record commands *before* they get executed, to prevent hijacking
      # the console auditing system (or, at least, knowing if someone tries)
    end

    def after_executing(statements)
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

    def show_warning(message)
      puts ColorizedString.new("\n\n#{message}\n").yellow
    end

    def extend_irb
      IRB::WorkSpace.prepend(Console1984::CommandsSniffer)
      IRB::Context.prepend(Console1984::ProtectedContext)
      Rails::ConsoleMethods.include(Console1984::Commands)
    end

    def ask_for_reason
      puts ColorizedString.new("#{user&.humanize}, please enter the reason for this console access:").green
      reason = $stdin.gets.strip until reason.present?
      reason
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
end
