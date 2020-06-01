class Console1984::Supervisor::EncryptionMode::Protected
  def execute(&block)
    ActiveRecordEncryption.protecting_encrypted_data(&block)
  end

  private
    def null_encryptor
      @null_encryptor ||= ActiveRecordEncryption::NullEncryptor.new
    end
end
