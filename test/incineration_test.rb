require "test_helper"

class IncinerationTest < ActiveSupport::TestCase
  test "incinerating sessions 30 days after their creation" do
    freeze_time

    assert_enqueued_with job: Console1984::IncinerationJob, at: 30.days.from_now do
      console = SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason")
      console.execute "1+1"
      type_when_prompted "Create trail data to test its deletion" do
        console.execute "decrypt!"
      end
      console.execute "2+2"
    end

    travel_to 30.days.from_now.utc do
      assert_difference -> { Console1984::Session.count }, -1 do
        assert_difference -> { Console1984::Command.count }, -3 do
          assert_difference -> { Console1984::SensitiveAccess.count }, -1 do
            perform_enqueued_jobs only: Console1984::IncinerationJob
          end
        end
      end
    end
  end

  test "skipping incineration" do
    original, Console1984.config.incinerate = Console1984.incinerate, false

    assert_no_enqueued_jobs only: Console1984::IncinerationJob do
      SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason")
    end
  ensure
    Console1984.config.incinerate = original
  end

  test "job reschedules when incineration period has increased" do
    original = Console1984.incinerate_after

    freeze_time

    session = console1984_sessions(:arithmetic)
    session.update! created_at: Time.now

    travel_to 30.days.from_now do
      Console1984.config.incinerate_after = 60.days

      assert_enqueued_with job: Console1984::IncinerationJob, at: session.created_at + 60.days do
        Console1984::IncinerationJob.perform_now(session)
      end

      assert_not session.destroyed?
    end
  ensure
    Console1984.config.incinerate_after = original
  end

  test "trying to incinerate a session ahead of time will raise" do
    freeze_time
    session = console1984_sessions(:arithmetic)
    session.update! created_at: Time.now

    assert_raise Console1984::Errors::ForbiddenIncineration do
      session.incinerate
    end

    travel_to 30.days.from_now.utc do
      assert_nothing_raised do
        session.incinerate
      end
    end
  end
end
