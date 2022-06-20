# A username resolver that returns the value of a given
# environment variable.
class Console1984::Username::EnvResolver
  include Console1984::Freezeable

  def initialize(key)
    @key = key
  end

  def current
    "#{username}"
  end

  private
    def username
      @username ||= ENV[@key]
    end
end
