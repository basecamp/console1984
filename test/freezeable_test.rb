require "test_helper"

class FreezeableTest < ActiveSupport::TestCase
  test "prevent_instance_data_manipulation_after_freezing defaults to true" do
    klass = Class.new { include Console1984::Freezeable }

    assert_equal true, klass.prevent_instance_data_manipulation_after_freezing
  end

  test "prevent_instance_data_manipulation_after_freezing survives ActiveSupport::IsolatedExecutionState being cleared" do
    # Reproduces the boot symptom of an app running +isolation_level = :fiber+: gem eager-load writes
    # the opt-out, then Rails switches the level in +after_initialize+, clearing the boot scope's
    # storage before +freeze_all+ reads the flag. The write must survive.
    klass = Class.new do
      include Console1984::Freezeable
      self.prevent_instance_data_manipulation_after_freezing = false
    end

    ActiveSupport::IsolatedExecutionState.clear

    assert_equal false, klass.prevent_instance_data_manipulation_after_freezing
  end

  test "prevent_instance_data_manipulation_after_freezing is independent per including host" do
    one = Class.new { include Console1984::Freezeable }
    two = Class.new { include Console1984::Freezeable }

    one.prevent_instance_data_manipulation_after_freezing = false

    assert_equal false, one.prevent_instance_data_manipulation_after_freezing
    assert_equal true, two.prevent_instance_data_manipulation_after_freezing
  end

  test "subclasses keep their own value, defaulting to true like thread_mattr_accessor did" do
    parent = Class.new { include Console1984::Freezeable }
    parent.prevent_instance_data_manipulation_after_freezing = false
    child = Class.new(parent)

    assert_equal true, child.prevent_instance_data_manipulation_after_freezing

    child.prevent_instance_data_manipulation_after_freezing = true

    assert_equal false, parent.prevent_instance_data_manipulation_after_freezing
  end

  test "Console1984::Ext::Core::Object opt-out does not leak into other Freezeable hosts" do
    # Object includes Console1984::Ext::Core::Object, which sets the flag to false. A class-variable-backed
    # accessor would propagate that false through Ruby's ancestor chain to every descendant of Object,
    # silently disabling the protection on every other Freezeable host.
    assert_equal false, Console1984::Ext::Core::Object.prevent_instance_data_manipulation_after_freezing
    assert_equal true, Console1984::Config.prevent_instance_data_manipulation_after_freezing
  end
end
