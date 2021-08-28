module Console1984::Commands
  include Console1984::Freezeable

  def decrypt!
    supervisor.enable_access_to_encrypted_content
  end

  def encrypt!
    supervisor.disable_access_to_encrypted_content
  end

  private
    def supervisor
      Console1984.supervisor
    end
end
