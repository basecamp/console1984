# Add Console 1984 commands to IRB sessions.
module Console1984::Ext::Irb::Commands
  include Console1984::Freezeable

  delegate :shield, to: Console1984

  # Enter {unprotected mode}[rdoc-ref:Console1984::Shield::Modes] mode.
  def decrypt!
    shield.enable_unprotected_mode
  end

  # Enter {protected mode}[rdoc-ref:Console1984::Shield::Modes] mode.
  def encrypt!
    shield.enable_protected_mode
  end

  # This returns the last error that prevented a command execution in the console
  # or nil if there isn't any.
  #
  # This is meant for internal usage when debugging legit commands that are wrongly
  # prevented.
  def _console_last_suspicious_command_error
    Console1984.command_executor.last_suspicious_command_error
  end
end
