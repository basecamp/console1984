# Prevents adding new methods to classes.
#
# This prevents manipulating certain Console1984 classes
# during a console session.
module Console1984::Freezeable
  extend ActiveSupport::Concern

  mattr_reader :to_freeze, default: Set.new

  included do
    Console1984::Freezeable.to_freeze << self
  end

  class_methods do
    SENSITIVE_INSTANCE_METHODS = %i[ instance_variable_set ]
    SENSITIVE_CLASS_METHODS = %i[ class_variable_set ]

    def prevent_sensitive_overrides
      SENSITIVE_INSTANCE_METHODS.each do |method|
        prevent_sensitive_method method
      end

      class_eval do
        SENSITIVE_CLASS_METHODS.each do |method|
          prevent_sensitive_method method
        end
      end
    end

    private
      def prevent_sensitive_method(method_name)
        define_method method_name do |*arguments|
          raise Console1984::Errors::ForbiddenCodeManipulation, "You can't invoke #{method_name} on #{self}"
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
