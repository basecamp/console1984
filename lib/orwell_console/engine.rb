require 'irb'

puts 'ENGINE'
module OrwellConsole
  class Engine < ::Rails::Engine
    isolate_namespace OrwellConsole

    config.orwell_console = ActiveSupport::OrderedOptions.new

    initializer 'orwell_console.configs' do
      OrwellConsole.audit_logger = config.orwell_console.audit_logger || ActiveSupport::Logger.new(STDOUT)

      OrwellConsole.big_brother = BigBrother.new
    end

    console do
      OrwellConsole.big_brother.supervise if OrwellConsole.running_protected_environment?
    end
  end
end
