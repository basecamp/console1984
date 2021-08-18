module Console1984::FrozenMethods
  extend ActiveSupport::Concern

  module ClassMethods
    def method_added(method_name)
      raise Console1984::Errors::ForbiddenClassManipulation, "Can't override #{name}##{method_name}"
    end

    def singleton_method_added(method_name)
      raise Console1984::Errors::ForbiddenClassManipulation, "Can't override #{name}.#{method_name}"
    end
  end
end
