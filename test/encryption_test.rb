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
    @console.execute "decrypt!"

    @console.execute <<~RUBY
      puts Person.find(#{@person.id}).name
    RUBY

    assert_includes @console.output, @person.name
  end

  test "encrypt! will hide encrypted attributes" do
    @console.execute "decrypt!"
    @console.execute "encrypt!"

    @console.execute <<~RUBY
      puts Person.find(#{@person.id}).name
    RUBY

    assert_not_includes @console.output, @person.name
  end

  test "can't modify encrypted attributes in protected mode" do
    assert_raises ActiveRecord::RecordInvalid do
      @console.execute <<~RUBY
        person = Person.find(#{@person.id})
        person.update! name: "Other name"
      RUBY
    end
  end

  test "can modify unencrypted attributes in unprotected mode" do
    @console.execute "decrypt!"

    assert_nothing_raised do
      @console.execute <<~RUBY
        person = Person.find(#{@person.id})
        person.update! email: "other@email.com"
      RUBY
    end

    assert_equal "other@email.com", @person.reload.email
  end

  test "can modify encrypted attributes in unprotected mode" do
    @console.execute "decrypt!"

    assert_nothing_raised do
      @console.execute <<~RUBY
        person = Person.find(#{@person.id})
        person.update! name: "Other name"
      RUBY
    end

    assert_equal "Other name", @person.reload.name
  end
end
