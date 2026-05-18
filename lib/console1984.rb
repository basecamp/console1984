require 'console1984/engine'

require "zeitwerk"
class_loader = Zeitwerk::Loader.for_gem
class_loader.setup

# = Console 1984
#
# Console1984 is an IRB-based Rails console extension that does
# three things:
#
# * Record console sessions with their user, reason and commands.
# * Protect encrypted data by showing the ciphertexts when you visualize it.
# * Protect access to external systems that contain sensitive information (such as Redis
#   or Elasticsearch).
#
# == Session logging
#
# The console will record the session, its user and the commands entered. The logic to
# persist sessions is handled by the configured session logger, which is
# Console1984::SessionsLogger::Database by default.
#
# == Execution of commands
#
# The console will work in two modes:
#
# * Protected: It won't show encrypted information (it will show the ciphertexts instead)
#   and it won't allow connections to protected urls.
# * Unprotected: it allows access to encrypted information and protected urls. The commands
#   executed in this mode as flagged as sensitive.
#
# Console1984::CommandExecutor handles the execution of commands applying the corresponding
# protection mechanisms.´
#
# == Internal tampering prevention
#
# Finally, console1984 includes protection mechanisms against internal tampering while using
# the console. For example, to prevent the user from deleting audit trails. See
# Console1984::Shield and Console1984::CommandValidator to learn more.
module Console1984
  include Messages

  mattr_accessor :supervisor, default: Supervisor.new

  mattr_reader :config, default: Config.new

  mattr_accessor :class_loader

  class << self
    Config::PROPERTIES.each do |property|
      delegate property, to: :config
    end

    # Returns whether the console is currently running in protected mode or not.
    def running_protected_environment?
      protected_environments.collect(&:to_sym).include?(Rails.env.to_sym)
    end

    def require_ruby_parser_dependencies
      if RUBY_VERSION >= "3.3"
        require 'parser'
        require 'prism'
      else
        Kernel.silence_warnings do
          require 'parser/current'
        end
      end
    end

    # Returns the parser class used for parsing console commands.
    # Uses Prism on Ruby >= 3.3 for forward-compatibility with Ruby 4.0+.
    # Falls back to the parser gem on older Rubies.
    def ruby_parser
      if RUBY_VERSION >= "3.3"
        Prism::Translation::ParserCurrent
      else
        Parser::CurrentRuby
      end
    end
  end
end

Console1984.class_loader = class_loader
