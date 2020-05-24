require 'irb'

module OrwellConsole
  class Engine < ::Rails::Engine
    isolate_namespace OrwellConsole

    config.orwell_console = ActiveSupport::OrderedOptions.new
    config.orwell_console.protected_environments ||= %i[ production ]

    initializer 'orwell_console.configs' do
      OrwellConsole.protected_environments ||= config.orwell_console.protected_environments
      OrwellConsole.audit_logger = config.orwell_console.audit_logger || ActiveSupport::Logger.new(STDOUT)
    end

    initializer 'orwell_console.big_brother' do
      OrwellConsole.big_brother = BigBrother.new
    end

    console do
      puts "Es #{OrwellConsole.running_protected_environment?}: #{OrwellConsole.protected_environments}"
      OrwellConsole.big_brother.supervise if OrwellConsole.running_protected_environment?
    end
  end
end
