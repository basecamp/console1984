module Console1984::ProtectedObject
  extend ActiveSupport::Concern

  include Console1984::Freezeable

  class_methods do
    def const_get(*arguments)
      if Console1984.supervisor.executing_user_command? && arguments.first.to_s =~ /Console1984|ActiveRecord/
        raise Console1984::Errors::ForbiddenCommand
      else
        super
      end
    end
  end
end