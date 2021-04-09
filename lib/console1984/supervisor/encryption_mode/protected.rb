class Console1984::Supervisor::EncryptionMode::Protected
  def execute(&block)
    ActiveRecord::Encryption.protecting_encrypted_data(&block)
  end

  private
    def null_encryptor
      @null_encryptor ||= ActiveRecord::Encryption::NullEncryptor.new
    end
end
