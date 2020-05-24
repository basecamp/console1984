class OrwellConsole::UsageSupervisor
  include OrwellConsole::Messages
  using Rainbow

  attr_reader :reason

  def supervise
    configure_loggers
    show_production_data_warning
    extend_irb
    @reason = ask_for_reason
  end

  def executed(statements)
    audit(statements)
  end

  private
    def configure_loggers
      configure_rails_loggers
      configure_structured_logger
    end

    def configure_rails_loggers
      Rails.logger = ActiveSupport::Logger.new(nil)
        .tap { |logger| logger.formatter = ::Logger::Formatter.new }
        .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
      Rails.application.config.structured_logging.logger = ActiveSupport::Logger.new(structured_logger_string_io)
      ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
      ActiveJob::Base.logger.level = :error
      STDOUT.sync = true
    end

    def structured_logger_string_io
      @structured_logger_io ||= StringIO.new
    end

    def configure_structured_logger
      RailsStructuredLogging::Recorder.instance.attach_to(ActiveRecord::Base.logger)
      RailsStructuredLogging::Subscriber.subscribe_to \
          "console.supervision.audit_trail",
        logger: Rails.application.config.structured_logging.logger,
        serializer: OrwellConsole::AuditTrailSerializer
    end

    def show_production_data_warning
      puts PRODUCTION_DATA_WARNING.red
    end

    def extend_irb
      IRB::WorkSpace.prepend(OrwellConsole::CommandsSniffer)
      Rails::ConsoleMethods.include(OrwellConsole::Commands)
    end

    def ask_for_reason
      puts "#{user&.humanize}, please enter the reason for this console access:".green
      reason = $stdin.gets.strip until reason.present?
      reason
    end

    def audit(statements)
      ActiveSupport::Notifications.instrument "console.supervision.audit_trail", \
        audit_trail: OrwellConsole::AuditTrail.new(user: user, reason: reason, statements: statements.join("\n"))
      ::LogAuditTrailJob.perform_later(read_audit_trail_json)
    end

    SEPARATOR = SecureRandom.alphanumeric(12)

    def read_audit_trail_json
      structured_logger_string_io.seek(@last_value ? structured_logger_string_io.pos - @last_value.bytesize : 0)
      @last_value = structured_logger_string_io.gets
    end

    def user
      ENV["CONSOLE_USER"] ||= "Unnamed" if Rails.env.development? || Rails.env.test?
      ENV["CONSOLE_USER"] or raise "$CONSOLE_USER not defined. Can't run console unless identified"
    end
end
