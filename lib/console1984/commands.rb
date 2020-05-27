module Console1984::Commands
  def decrypt!
    Console1984.supervisor.enable_access_to_encrypted_content
  end

  def encrypt!
    Console1984.supervisor.disable_access_to_encrypted_content
  end
end
