class Console1984::Supervisor::EncryptionMode::Protected
  def execute(&block)
    ActiveRecordEncryption.with_encryption_context(encryptor: null_encryptor, frozen_encryption: true, &block)
  end

  private
    def null_encryptor
      @null_encryptor ||= ActiveRecordEncryption::NullEncryptor.new
    end
end
