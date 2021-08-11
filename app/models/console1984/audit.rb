module Console1984
  class Audit < Base
    belongs_to :session
    belongs_to :auditor, class_name: Console1984.auditor_class

    enum status: %i[ pending approved flagged ]

    encrypts :notes
  end
end
