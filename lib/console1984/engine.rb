require 'irb'

module Console1984
  class Engine < ::Rails::Engine
    isolate_namespace Console1984

    config.console1984 = ActiveSupport::OrderedOptions.new
    config.console1984.protected_environments ||= %i[ production ]
    config.console1984.protected_urls ||= []

    initializer "console1984.config" do
      config.console1984.each do |key, value|
        Console1984.config.send("#{key}=", value)
      end
    end

    # Console 1984 setup happens when a console is started. Just including the
    # gem won't install any protection mechanisms.
    console do
      Console1984.config.set_from(config.console1984)

      if Console1984.running_protected_environment?
        Console1984.supervisor.install
        Console1984.supervisor.start
      end
    end
  end
end
