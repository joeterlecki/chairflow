require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  setup do
    @stylist = Stylist.create!(name: "Alex")
    @client = Client.create!(name: "Taylor")
    @start = Time.zone.local(2026, 9, 24, 10)
    @booking = Appointment.create!(stylist: @stylist, client: @client, service: "Cut & finish", starts_at: @start, duration_minutes: 60)
  end

  test "rejects overlapping bookings including one surrounding an existing appointment" do
    [ [ -30, 60 ], [ 30, 60 ], [ -30, 120 ], [ 0, 30 ] ].each do |offset, duration|
      booking = build_booking(starts_at: @start + offset.minutes, duration_minutes: duration)
      assert_not booking.valid?
      assert booking.errors[:base].any?
    end
  end

  test "allows back to back bookings and other stylists" do
    assert build_booking(starts_at: @start + 1.hour).valid?
    assert build_booking(starts_at: @start - 1.hour).valid?
    assert build_booking(stylist: Stylist.create!(name: "Jamie")).valid?
    assert @booking.valid?
  end

  test "recalculates the end when moving an existing appointment" do
    @booking.update!(starts_at: @start + 2.hours, duration_minutes: 90)
    assert_equal @start + 210.minutes, @booking.reload.ends_at
  end

  test "rejects missing client, invalid duration and overnight appointments" do
    assert_not build_booking(client: nil).valid?
    assert_not build_booking(duration_minutes: 0).valid?
    assert_not build_booking(starts_at: @start.change(hour: 23, min: 30)).valid?
  end

  private

  def build_booking(**attributes)
    Appointment.new({ stylist: @stylist, client: @client, service: "Cut & finish", starts_at: @start, duration_minutes: 60 }.merge(attributes))
  end
end
