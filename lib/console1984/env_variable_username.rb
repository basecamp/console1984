class Console1984::EnvVariableUsername
  def initialize(key)
    @username = ENV[key]
  end

  def current_user_name
    @username
  end
end
