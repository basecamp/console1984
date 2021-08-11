module Console1984
  class SensitiveAccess < Base
    belongs_to :session
    has_many :commands
  end
end
