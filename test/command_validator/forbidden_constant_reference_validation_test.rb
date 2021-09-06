require "test_helper"

class ForbiddenConstantReferenceValidationTest < ActiveSupport::TestCase
  test "validate referencing constant that are always forbidden will raise a ForbiddenCommandAttempted error" do
    assert_raise Console1984::Errors::ForbiddenCommandAttempted do
      run_validation <<~RUBY, always: ["SomeClass"]
        SomeClass.some_method
      RUBY
    end
  end

  test "validate referencing namespaced constants that are always forbidden will raise a ForbiddenCommandAttempted error" do
    assert_raise Console1984::Errors::ForbiddenCommandAttempted do
      run_validation <<~RUBY, always: ["Some::Base::Class"]
        puts Some::Base::Class.config
      RUBY
    end
  end

  test "validate referencing a namespaced constant where the parent constant is banned" do
    assert_raise Console1984::Errors::ForbiddenCommandAttempted do
      run_validation <<~RUBY, always: ["Some"]
        puts Some::Base::Class.config
      RUBY
    end
  end

  test "validate constants with leading ::" do
    assert_raise Console1984::Errors::ForbiddenCommandAttempted do
      run_validation <<~RUBY, always: ["Some"]
        puts ::Some::Base::Class.config
      RUBY
    end
  end

  test "validate referencing constant that are forbidden in protected mode will raise a ForbiddenCommandAttempted error only in protected mode" do
    run_validation <<~RUBY, protected: ["SomeClass"], shield: OpenStruct.new(protected_mode?: false)
      SomeClass.some_method
    RUBY

    assert_raise Console1984::Errors::ForbiddenCommandAttempted do
      run_validation <<~RUBY, protected: ["SomeClass"], shield: OpenStruct.new(protected_mode?: true)
        SomeClass.some_method
      RUBY
    end
  end

  test "referencing other constants won't raise any error" do
    run_validation <<~RUBY, always: ["SomeConstant"]
      SomeNotForbiddenClass.some_method
    RUBY
  end

  test "doesn't prevent referencing constants that only match partially" do
    run_validation <<~RUBY, always: ["SomeClass"]
      SomeClass2.some_method
    RUBY
  end

  private
    def run_validation(command, shield: Console1984.shield, always: [], protected: [])
      validation = Console1984::CommandValidator::ForbiddenConstantReferenceValidation.new \
        shield,
        always: always,
        protected: protected

      parsed_command = Console1984::CommandValidator::ParsedCommand.new(command)
      validation.validate parsed_command
    end
end
