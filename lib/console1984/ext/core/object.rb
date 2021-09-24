# Prevents loading forbidden classes dynamically.
#
# There are classes that we don't want to allow loading dynamically
# during a console session. For example, we don't want users to reference
# the constant +Console1984+. We will prevent a direct constant reference
# but users could still do:
#
#    MyConstant = ("Con" + "sole1984").constantize
#
# We prevent this by extending +Object#const_get+.
module Console1984::Ext::Core::Object
  extend ActiveSupport::Concern

  include Console1984::Freezeable
  self.prevent_instance_data_manipulation_after_freezing = false

  class_methods do
    def const_get(*arguments)
      if Console1984.command_executor.from_irb?(caller)
        begin
          # To validate if it's an invalid constant, we try to declare a class with it.
          # We essentially leverage Console1984::CommandValidator::ForbiddenReopeningValidation here:
          # We don't let referencing constants referring modules or classes we don't allow to extend.
          #
          # See the list +forbidden_reopening+ in +config/command_protections.yml+.
          Console1984.command_executor.validate_command("class #{arguments.first}; end")
          super
        rescue Console1984::Errors::ForbiddenCommandAttempted
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
