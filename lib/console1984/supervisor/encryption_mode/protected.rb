class Console1984::Supervisor::EncryptionMode::Protected
  def execute(&block)
    Console1984.protecting_connections do
      ActiveRecord::Encryption.protecting_encrypted_data(&block)
    end
  end

  private
    def null_encryptor
      @null_encryptor ||= ActiveRecord::Encryption::NullEncryptor.new
    end
end
