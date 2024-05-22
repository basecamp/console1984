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
end
