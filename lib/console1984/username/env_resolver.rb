class Console1984::Username::EnvResolver
  def initialize(key)
    @key = key
  end

  def current
    "#{username}"
  end

  private
    def username
      @username ||= ENV[@key]&.humanize || "Unnamed"
    end
end
