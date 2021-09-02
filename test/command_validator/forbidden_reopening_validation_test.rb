require "test_helper"

class ForbiddenReopeningValidationTest < ActiveSupport::TestCase
  test "validate reopening classes that are always forbidden will raise a ForbiddenCommand error" do
    assert_raise Console1984::Errors::ForbiddenCommand do
      run_validation <<~RUBY, ["SomeClass"]
        class SomeClass
        end
      RUBY
    end
  end

  test "validate reopening modules that are always forbidden will raise a ForbiddenCommand error" do
    assert_raise Console1984::Errors::ForbiddenCommand do
      run_validation <<~RUBY, ["SomeModule"]
        module SomeModule
        end
      RUBY
    end
  end

  test "validate reopening namespaced classes" do
    assert_raise Console1984::Errors::ForbiddenCommand do
      run_validation <<~RUBY, ["Some::Base::Class"]
        class Some::Base::Class
        end
      RUBY
    end
  end

  test "validate reopening namespaced classes when the parent module is banned" do
    assert_raise Console1984::Errors::ForbiddenCommand do
      run_validation <<~RUBY, ["Some"]
        module Some::Base::Class
        end
      RUBY
    end
  end

  private
    def run_validation(command, banned_classes_or_modules)
      validation = Console1984::CommandValidator::ForbiddenReopeningValidation.new(banned_classes_or_modules)

      parsed_command = Console1984::CommandValidator::ParsedCommand.new(command)
      validation.validate parsed_command
    end
end
