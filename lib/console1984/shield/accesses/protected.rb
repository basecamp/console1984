class Console1984::Shield::Accesses::Protected
  include Console1984::Freezeable

  def execute(&block)
    Console1984.protecting(&block)
  end

  private
    def null_encryptor
      @null_encryptor ||= ActiveRecord::Encryption::NullEncryptor.new
    end
end
