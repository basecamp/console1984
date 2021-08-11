module Console1984
  class User < Base
    has_many :sessions, dependent: :destroy
  end
end
