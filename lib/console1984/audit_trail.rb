class Console1984::AuditTrail
  attr_reader :session_id, :user, :commands, :access_reason, :sensitive

  def initialize(session_id:, user:, access_reason:, commands:, sensitive: false)
    @session_id = session_id
    @user = user
    @access_reason = access_reason
    @commands = commands
    @sensitive = sensitive
  end
end
