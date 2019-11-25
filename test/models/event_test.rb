# test/models/event_test.rb

require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "one simple test example" do
    Event.create kind: "opening", starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: "appointment", starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal "2014/08/10", availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal "2014/08/11", availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal [], availabilities[2][:slots]
    assert_equal "2014/08/16", availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

  test "multiple openings and appointments slots" do
    Event.create kind: "opening", starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: "opening", starts_at: DateTime.parse("2014-08-04 13:30"), ends_at: DateTime.parse("2014-08-04 16:30")
    Event.create kind: "appointment", starts_at: DateTime.parse("2014-08-04 10:30"), ends_at: DateTime.parse("2014-08-04 11:30")
    Event.create kind: "appointment", starts_at: DateTime.parse("2014-08-04 11:30"), ends_at: DateTime.parse("2014-08-04 12:00")
    Event.create kind: "appointment", starts_at: DateTime.parse("2014-08-04 13:30"), ends_at: DateTime.parse("2014-08-04 14:00")
    Event.create kind: "appointment", starts_at: DateTime.parse("2014-08-04 15:00"), ends_at: DateTime.parse("2014-08-04 16:00")

    availabilities = Event.availabilities DateTime.parse("2014-08-04")
    assert_equal "2014/08/04", availabilities[0][:date]
    assert_equal ["9:30", "10:00", "12:00", "14:00", "14:30", "16:00"], availabilities[0][:slots]
  end

  test "appointments are not during an opening slot time" do
    Event.create kind: "opening", starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: "appointment", starts_at: DateTime.parse("2014-08-11 13:30"), ends_at: DateTime.parse("2014-08-11 14:00")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal "2014/08/11", availabilities[1][:date]
    assert_equal ["9:30", "10:00", "10:30", "11:00", "11:30", "12:00"], availabilities[1][:slots]
  end

  test "appointment last longer than the opening time frame" do
    Event.create kind: "opening", starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: "appointment", starts_at: DateTime.parse("2014-08-11 09:30"), ends_at: DateTime.parse("2014-08-11 14:00")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal "2014/08/11", availabilities[1][:date]
    assert_equal [], availabilities[1][:slots]
  end

  test "no opening slot" do
    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal "2014/08/11", availabilities[1][:date]
    assert_equal [], availabilities[1][:slots]
  end

  test "no availabilities slot" do
    Event.create kind: "opening", starts_at: DateTime.parse("2014-08-04 10:30"), ends_at: DateTime.parse("2014-08-04 11:30"), weekly_recurring: true
    Event.create kind: "appointment", starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal "2014/08/11", availabilities[1][:date]
    assert_equal [], availabilities[1][:slots]
  end

  test "non :00 or :30 slots starting hours" do
    Event.create kind: "opening", starts_at: DateTime.parse("2014-08-04 09:45"), ends_at: DateTime.parse("2014-08-04 12:45"), weekly_recurring: true
    Event.create kind: "appointment", starts_at: DateTime.parse("2014-08-11 10:45"), ends_at: DateTime.parse("2014-08-11 11:45")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal "2014/08/11", availabilities[1][:date]
    assert_equal ["9:45", "10:15", "11:45", "12:15"], availabilities[1][:slots]
  end

  test "weekly recurring event starting after the current week" do
    Event.create kind: "opening", starts_at: DateTime.parse("2014-08-18 09:30"), ends_at: DateTime.parse("2014-08-18 12:30"), weekly_recurring: true
    Event.create kind: "appointment", starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal "2014/08/11", availabilities[1][:date]
    assert_equal [], availabilities[1][:slots]
  end
end
