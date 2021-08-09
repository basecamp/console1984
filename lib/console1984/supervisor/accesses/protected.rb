class Console1984::Supervisor::Accesses::Protected
  def execute(&block)
    Console1984.protecting(&block)
  end

  private
    def null_encryptor
      @null_encryptor ||= ActiveRecord::Encryption::NullEncryptor.new
    end
end
