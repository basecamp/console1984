class Console1984::EncryptionMode::Protected
  def execute(&block)
    ActiveRecordEncryption.with_encryption_context(encryptor: read_only_null_encryptor, frozen_encryption: true, &block)
  end

  private
    def read_only_null_encryptor
      @read_only_null_encryptor ||= ActiveRecordEncryption::ReadOnlyNullEncryptor.new
    end
end
