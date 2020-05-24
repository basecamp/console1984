module OrwellConsole
  class Engine < ::Rails::Engine
    isolate_namespace OrwellConsole

    config.orwell_console = ActiveSupport::OrderedOptions.new

    console do
      if OrwellConsole.running_protected_environment?
        OrwellConsole.usage_supervisor.supervise
      end
    end

    initializer "orwell_console.configs" do
      config.after_initialize do |app|
      end
    end
  end
end
