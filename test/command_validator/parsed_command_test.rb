require "test_helper"

class ParsedCommandTest < ActiveSupport::TestCase
  test "parse constants" do
    assert_constants ["Topic"], <<~RB
      Topic.last.name
    RB

    assert_constants ["Incineratable", "Topic", "ActiveRecord::Base::Whatever"], <<~RB
      include Incineratable
      Topic.last
      ActiveRecord::Base::Whatever.connection = :whatever
    RB

    assert_constants ["Bar", "Foo"], <<~RB
      def method(foo = Bar)
        foo = Foo.from_config
      end
    RB

    assert_constants ["SomeClass"], <<~RB
      ::SomeClass.hi
    RB
  end

  test "parse declarations" do
    assert_declaration ["Topic", "Book", "People", "Some::Base::Class", "MyClass", "MyModule"], <<~RB
      class Topic
      end

      class Book < ActiveRecord::Base
      end

      module People
      end

      class Some::Base::Class
      end

      module MyModule
        class MyClass
        end
      end
    RB
  end

  test "parse declaration that starts with identifier" do
    assert_declaration [], <<~RB
      t = Topic
      class t::Subtopic
      end
    RB
  end

  test "parse constant assignments" do
    assert_constant_assignment ["Topic"], <<~RB
      MyTopic = Topic
    RB

    assert_constant_assignment ["Topic"], <<~RB
      MyTopic = MyOtherTopic = Topic
    RB
  end

  test "syntax errors are handled gracefully" do
    parsed_command = Console1984::CommandValidator::ParsedCommand.new <<~RB
      def 12'39u````
    RB

    assert_equal [], parsed_command.constants
    assert_equal [], parsed_command.declared_classes_or_modules
  end

  private
    def assert_constants(expected_constants, source)
      parsed_command = Console1984::CommandValidator::ParsedCommand.new(source)
      assert_equal expected_constants, parsed_command.constants
    end

    def assert_declaration(expected_constants, source)
      parsed_command = Console1984::CommandValidator::ParsedCommand.new(source)
      assert_equal expected_constants, parsed_command.declared_classes_or_modules
    end

    def assert_constant_assignment(expected_constants, source)
      parsed_command = Console1984::CommandValidator::ParsedCommand.new(source)
      assert_equal expected_constants, parsed_command.constant_assignments
    end
end
