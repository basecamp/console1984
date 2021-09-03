require "test_helper"

class EncryptionTest < ActiveSupport::TestCase
  setup do
    @console = SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason")
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
    execute_decrypt_and_enter_reason

    @console.execute <<~RUBY
      puts Person.find(#{@person.id}).name
    RUBY

    assert_includes @console.output, @person.name
  end

  test "encrypt! will hide encrypted attributes" do
    execute_decrypt_and_enter_reason
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
    execute_decrypt_and_enter_reason

    assert_nothing_raised do
      @console.execute <<~RUBY
        person = Person.find(#{@person.id})
        person.update! email: "other@email.com"
      RUBY
    end
    assert_equal "other@email.com", @person.reload.email
  end

  test "can modify encrypted attributes in unprotected mode" do
    execute_decrypt_and_enter_reason

    # assert_nothing_raised do
    @console.execute <<~RUBY
        person = Person.find(#{@person.id})
        person.update! name: "Other name"
    RUBY
    # end

    puts @console.output

    # assert_equal "Other name", @person.reload.name
  end

  private
    def execute_decrypt_and_enter_reason
      type_when_prompted "I need to fix encoding issue with Message 123456" do
        @console.execute "decrypt!"
      end
    end
end
