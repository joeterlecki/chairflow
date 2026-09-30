require "test_helper"

class SalonDayTest < ActiveSupport::TestCase
  test "wday must be 0 through 6" do
    day = SalonDay.new(wday: 7, opens_minute: 480, closes_minute: 1080)
    assert_not day.valid?
    assert_includes day.errors[:wday], "is not included in the list"
  end

  test "wday is unique" do
    day = SalonDay.new(wday: salon_days(:sunday).wday, opens_minute: 480, closes_minute: 1080)
    assert_not day.valid?
    assert_includes day.errors[:wday], "has already been taken"
  end

  test "opens_minute and closes_minute must be within a day" do
    day = SalonDay.new(wday: 2, opens_minute: -15, closes_minute: 1080)
    assert_not day.valid?
    assert_includes day.errors[:opens_minute], "is not included in the list"
  end

  test "closing time must be after opening time" do
    day = SalonDay.new(wday: 2, opens_minute: 1080, closes_minute: 480)
    assert_not day.valid?
    assert_includes day.errors[:closes_minute], "needs to be after opening"
  end

  test "times must land on the 15-minute grid" do
    day = SalonDay.new(wday: 2, opens_minute: 481, closes_minute: 1080)
    assert_not day.valid?
    assert_includes day.errors[:base], "Times need to be on the quarter hour"
  end

  test "hours_on returns nil for a closed day" do
    assert_nil SalonDay.hours_on(Date.new(2026, 10, 5)) # a Monday, closed in fixtures
  end

  test "hours_on returns nil when there is no row for that weekday" do
    assert_nil SalonDay.hours_on(Date.new(2026, 10, 6)) # a Tuesday, no fixture
  end

  test "hours_on returns the range for an open day" do
    range = SalonDay.hours_on(Date.new(2026, 10, 4)) # a Sunday
    assert_equal "08:00", range.begin.strftime("%H:%M")
    assert_equal "18:00", range.end.strftime("%H:%M")
  end

  test "8:00 stays 8:00 across fall back" do
    day = SalonDay.new(wday: 0, opens_minute: 480, closes_minute: 1080)
    assert_equal "08:00", day.range_on(Date.new(2026, 11, 1)).begin.strftime("%H:%M")
  end

  test "8:00 stays 8:00 across spring forward" do
    day = SalonDay.new(wday: 0, opens_minute: 480, closes_minute: 1080)
    assert_equal "08:00", day.range_on(Date.new(2027, 3, 14)).begin.strftime("%H:%M")
  end
end
