# Freezes classes to prevent tampering them
class Console1984::Refrigerator
  include Console1984::Freezeable

  def freeze_all
    eager_load_all_classes
    freeze_internal_instances # internal modules and classes are frozen by including Console1984::Freezable
    freeze_external_modules_and_classes

    Console1984::Freezeable.freeze_all
  end

  private
    EXTERNAL_MODULES_AND_CLASSES_TO_FREEZE = [Parser::CurrentRuby]

    def freeze_internal_instances
      Console1984.config.freeze unless Console1984.config.test_mode
    end

    def freeze_external_modules_and_classes
      EXTERNAL_MODULES_AND_CLASSES_TO_FREEZE.each { |klass| klass.include(Console1984::Freezeable) }
    end

    def eager_load_all_classes
      Rails.application.eager_load! unless Rails.application.config.eager_load
      Console1984.class_loader.eager_load
    end
end

class Parser::Ruby27
  include Console1984::Freezeable
end
