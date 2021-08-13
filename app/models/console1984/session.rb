module Console1984
  class Session < Base
    include Auditable, Incineratable, Iterable

    belongs_to :user
    has_many :commands, dependent: :destroy
    has_many :sensitive_accesses, dependent: :destroy

    def sensitive?
      sensitive_accesses.any?
    end
  end
end
