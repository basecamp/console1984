require 'irb'

module Console1984
  class Engine < ::Rails::Engine
    isolate_namespace Console1984

    config.console1984 = ActiveSupport::OrderedOptions.new
    config.console1984.protected_environments ||= %i[ production ]

    console do
      Console1984.protected_environments ||= config.console1984.protected_environments
      Console1984.audit_logger = config.console1984.audit_logger || ActiveSupport::Logger.new(STDOUT)
      Console1984.supervisor = Supervisor.new
      Console1984.supervisor.start if Console1984.running_protected_environment?
    end
  end
end
