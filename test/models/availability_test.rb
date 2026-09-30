require "test_helper"

class AvailabilityTest < ActiveSupport::TestCase
  # 2026-10-04 is a Sunday; salon_days(:sunday) is open 08:00-18:00.
  OPEN_DATE = Date.new(2026, 10, 4)

  def open_slots(stylist:, duration:, date: OPEN_DATE)
    Availability.new(stylist: stylist, date: date, duration: duration).open_slots
  end

  def book(stylist:, starts_at:, duration_minutes:, status: :booked)
    Appointment.create!(
      client: clients(:ava),
      stylist: stylist,
      starts_at: starts_at,
      status: status,
      appointment_services_attributes: [ { service: services(:cut_and_finish), position: 1, duration_minutes: duration_minutes } ]
    )
  end

  test "a closed day has no open slots" do
    assert_empty open_slots(stylist: stylists(:melissa), duration: 30.minutes, date: Date.new(2026, 10, 5)) # Monday, closed
  end

  test "a duration longer than any gap returns none" do
    assert_empty open_slots(stylist: stylists(:melissa), duration: 601.minutes) # window is 600 minutes
  end

  test "a slot ending exactly at closing time is open" do
    slots = open_slots(stylist: stylists(:melissa), duration: 60.minutes)
    assert_includes slots.map { |t| t.strftime("%H:%M") }, "17:00"
  end

  test "a slot starting exactly when an appointment ends is open" do
    starts_at = Time.zone.parse("2026-10-04 09:00")
    book(stylist: stylists(:melissa), starts_at: starts_at, duration_minutes: 45) # ends 09:45

    slots = open_slots(stylist: stylists(:melissa), duration: 30.minutes)
    assert_includes slots.map { |t| t.strftime("%H:%M") }, "09:45"
    assert_not_includes slots.map { |t| t.strftime("%H:%M") }, "09:30"
  end

  test "cancelled appointments don't block" do
    starts_at = Time.zone.parse("2026-10-04 09:00")
    book(stylist: stylists(:melissa), starts_at: starts_at, duration_minutes: 45, status: :cancelled)

    slots = open_slots(stylist: stylists(:melissa), duration: 30.minutes)
    assert_includes slots.map { |t| t.strftime("%H:%M") }, "09:00"
  end

  test "45-minute totals land on the 15-minute grid" do
    slots = open_slots(stylist: stylists(:melissa), duration: 45.minutes)

    assert slots.all? { |t| (t.min % 15).zero? }
    assert_equal "08:00", slots.first.strftime("%H:%M")
    assert_equal "17:15", slots.last.strftime("%H:%M") # 17:15 + 45 min = 18:00, the closing time
  end
end
