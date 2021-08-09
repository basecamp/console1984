module Console1984
  class Command < Base
    belongs_to :session
    belongs_to :sensitive_access, optional: true

    encrypts :statements

    def sensitive?
      sensitive_access.present?
    end
  end
end
