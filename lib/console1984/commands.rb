module Console1984::Commands
  include Console1984::Freezeable

  delegate :shield, to: Console1984

  def decrypt!
    shield.enable_unprotected_mode
  end

  def encrypt!
    shield.enable_protected_mode
  end
end
