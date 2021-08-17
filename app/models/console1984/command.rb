module Console1984
  class Command < Base
    belongs_to :session
    belongs_to :sensitive_access, optional: true

    encrypts :statements

    scope :sorted_chronologically, -> { order(created_at: :asc, id: :asc) }

    def sensitive?
      sensitive_access.present?
    end
  end
end
