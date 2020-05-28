class Console1984::Supervisor::EncryptionMode::Unprotected
  def execute(&block)
    block.call
  end
end
