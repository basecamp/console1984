require "test_helper"

class EncryptionTest < ActiveSupport::TestCase
  setup do
    @console = SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason", capture_log_trails: false)
    @person = people(:julia)
  end

  teardown do
    @console.stop
  end

  test "show attributes encrypted by default" do
    @console.execute <<~RUBY
      puts Person.find(#{@person.id}).name
    RUBY

    assert_not_includes @console.output, @person.name
  end

  test "decrypt! will reveal encrypted attributes" do
    @console.execute <<~RUBY
      decrypt!
      puts Person.find(#{@person.id}).name
    RUBY

    assert_includes @console.output, @person.name
  end

  test "encrypt! will hide encrypted attributes" do
    @console.execute <<~RUBY
      decrypt!
      encrypt!
      puts Person.find(#{@person.id}).name
    RUBY

    assert_not_includes @console.output, @person.name
  end
end
