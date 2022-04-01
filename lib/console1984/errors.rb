module Console1984
  module Errors
    # Attempt to access a protected url while in protected mode.
    class ProtectedConnection < StandardError
      def initialize(details)
        super "A connection attempt was prevented because it represents a sensitive access."\
          "Please run decrypt! and try again. You will be asked to justify this access: #{details}"
      end
    end

    # Attempt to execute a command that is not allowed. The system won't
    # execute such commands and will flag them as sensitive.
    class ForbiddenCommandAttempted < StandardError; end

    # A suspicious command was executed. The command will be flagged but the system
    # will let it run.
    class SuspiciousCommandAttempted < StandardError; end

    # A forbidden command was executed. The system will flag the command
    # and exit.
    class ForbiddenCommandExecuted < StandardError; end

    # Attempt to incinerate a session ahead of time as determined by
    # +config.console1984.incinerate_after+.
    class ForbiddenIncineration < StandardError; end

    # The console username is not set. Only raised when `config.ask_for_username_if_empty = false`.
    class MissingUsername < StandardError; end
  end
end
