# An execution mode that protects encrypted information and connection to external systems.
class Console1984::Shield::Modes::Protected
  include Console1984::Freezeable

  delegate :protected_urls, to: Console1984

  thread_mattr_accessor :currently_protected_urls, default: []

  # Materialize the thread attribute before freezing the class. +thread_mattr_accessor+ attributes rely on
  # setting a class variable the first time they are referenced, and that will fail in frozen classes
  # like this one.
  currently_protected_urls

  def execute(&block)
    protecting(&block)
  end

  private
    def protecting(&block)
      protecting_connections do
        ActiveRecord::Encryption.protecting_encrypted_data(&block)
      end
    end

    def protecting_connections
      old_currently_protected_urls = self.currently_protected_urls
      self.currently_protected_urls = protected_urls
      yield
    ensure
      self.currently_protected_urls = old_currently_protected_urls
    end
end
