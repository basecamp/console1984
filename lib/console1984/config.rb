# Container for config options.
#
# These config options are accessible via first-level reader methods at Console1984.
class Console1984::Config
  include Console1984::Freezeable, Console1984::Messages

  PROTECTIONS_CONFIG_FILE_PATH = Console1984::Engine.root.join("config/protections.yml")

  PROPERTIES = %i[
    session_logger username_resolver ask_for_username_if_empty shield command_executor
    protected_environments protected_urls
    production_data_warning enter_unprotected_encryption_mode_warning enter_protected_mode_warning
    incinerate incinerate_after incineration_queue
    protections_config
    base_record_class
    debug test_mode
  ]

  attr_accessor(*PROPERTIES)

  def initialize
    set_defaults
  end

  def set_from(properties)
    properties.each do |key, value|
      public_send("#{key}=", value) if value.present?
    end
  end

  # Initialize lazily so that it only gets instantiated during console sessions
  def protections_config
    @protections_config ||= Console1984::ProtectionsConfig.new(YAML.safe_load(File.read(PROTECTIONS_CONFIG_FILE_PATH)).symbolize_keys)
  end

  def freeze
    super
    [ protected_urls, protections_config ].each(&:freeze)
  end

  private
    def set_defaults
      self.session_logger = Console1984::SessionsLogger::Database.new
      self.username_resolver = Console1984::Username::EnvResolver.new("CONSOLE_USER")
      self.shield = Console1984::Shield.new
      self.command_executor = Console1984::CommandExecutor.new

      self.protected_environments = []
      self.protected_urls = []

      self.production_data_warning = DEFAULT_PRODUCTION_DATA_WARNING
      self.enter_unprotected_encryption_mode_warning = DEFAULT_ENTER_UNPROTECTED_ENCRYPTION_MODE_WARNING
      self.enter_protected_mode_warning = DEFAULT_ENTER_PROTECTED_MODE_WARNING

      self.incinerate = true
      self.incinerate_after = 30.days
      self.incineration_queue = "console1984_incineration"
      self.ask_for_username_if_empty = false

      self.base_record_class = "::ApplicationRecord"

      self.debug = false
      self.test_mode = false
    end
end
