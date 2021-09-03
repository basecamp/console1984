module Console1984::ProtectedObject
  extend ActiveSupport::Concern

  include Console1984::Freezeable

  class_methods do
    def const_get(*arguments)
      if Console1984.command_executor.executing_user_command?
        begin
          Console1984.command_executor.validate_command("class #{arguments.first}; end")
          super
        rescue Console1984::Errors::ForbiddenCommand
          raise
        rescue StandardError
          super
        end
      else
        super
      end
    end
  end

  private
    def banned_dynamic_constant_declaration?(arguments)
      Console1984.command_executor.validate_command("class #{arguments.first}; end")
    end
end
