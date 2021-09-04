# Prevents adding new methods to classes, changing class-state or
# accessing/overridden instance variables via reflection. This is meant to
# prevent manipulating certain Console1984 classes during a console session.
#
# Notice this won't prevent every state-modification command. You should
# handle special cases by overriding +#freeze+ (if necessary) and invoking
# freezing on the instance when it makes sense.
#
# For example: check Console1984::Config#freeze and Console1984::Shield#freeze_all.
#
# The "freezing" doesn't materialize when the mixin is included. When mixed in, it
# will store the host class or module in a list. Then a call to Console1984::Freezeable.freeze_all
# will look through all the modules/classes freezing them. This way, we can control
# the moment where we stop classes from being modifiable at setup time.
module Console1984::Freezeable
  extend ActiveSupport::Concern

  mattr_reader :to_freeze, default: Set.new

  included do
    Console1984::Freezeable.to_freeze << self
  end

  class_methods do
    SENSITIVE_INSTANCE_METHODS = %i[ instance_variable_get instance_variable_set ]

    def prevent_sensitive_overrides
      SENSITIVE_INSTANCE_METHODS.each do |method|
        prevent_sensitive_method method
      end
    end

    private
      def prevent_sensitive_method(method_name)
        define_method method_name do |*arguments|
          raise Console1984::Errors::ForbiddenCommand, "You can't invoke #{method_name} on #{self}"
        end
      end
  end

  class << self
    def freeze_all
      class_and_modules_to_freeze.each do |class_or_module|
        freeze_class_or_module(class_or_module)
      end
    end

    private
      def class_and_modules_to_freeze
        with_descendants(to_freeze)
      end

      def freeze_class_or_module(class_or_module)
        class_or_module.prevent_sensitive_overrides
        class_or_module.freeze
      end

      def with_descendants(classes_and_modules)
        classes_and_modules + classes_and_modules.grep(Class).flat_map(&:descendants)
      end
  end

  freeze
end
