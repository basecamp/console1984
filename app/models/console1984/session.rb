module Console1984
  class Session < Base
    belongs_to :user
    has_many :commands, dependent: :destroy
    has_many :sensitive_accesses, dependent: :destroy

    def sensitive?
      sensitive_accesses.any?
    end
  end
end
