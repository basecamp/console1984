module Console1984::Session::Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audits, dependent: :destroy

    scope :sensitive, ->{ joins(:sensitive_accesses) }
    scope :reviewed, ->{ joins(:audits) }
    scope :pending, ->{ where.not(id: reviewed) }
  end
end