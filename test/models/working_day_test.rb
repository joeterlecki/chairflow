require "test_helper"

class WorkingDayTest < ActiveSupport::TestCase
  setup do
    @stylist = Stylist.create!(name: "Alex")
    @day = @stylist.working_days.find_by!(weekday: 1)
    @day.update!(opens_at: "09:30", closes_at: "17:00", break_starts_at: "12:00", break_ends_at: "13:00")
    @client = Client.create!(name: "Taylor")
  end

  test "full duration must fit hours and avoid break, while adjacent appointments are allowed" do
    assert booking(9, 30).valid?
    assert booking(11).valid?
    assert booking(13).valid?
    assert booking(16).valid?
    [ [ 9, 0 ], [ 11, 15 ], [ 12, 0 ], [ 12, 45 ], [ 16, 15 ] ].each do |hour, minute|
      assert_not booking(hour, minute).valid?, "Expected #{hour}:#{minute} to be unavailable"
    end
  end

  test "closed day has no open slots and rejects booking" do
    @day.update!(closed: true)
    assert_not booking(10).valid?
    availability = DayAvailability.new(stylist: @stylist, starts_at: booking(10).starts_at, duration: 60)
    assert_empty availability.open_slots
    assert_equal "Day off", availability.unavailable_reason
  end

  test "invalid and partial break ranges cannot be saved" do
    assert_not @day.update(break_ends_at: "")
    @day.reload
    assert_not @day.update(break_starts_at: "08:00")
    @day.reload
    assert_not @day.update(break_ends_at: "11:00")
    @day.reload
    assert_not @day.update(closes_at: "08:00")
  end

  test "conflicting changes are rejected and legacy bookings can still have notes edited" do
    appointment = booking(10)
    appointment.save!
    assert_not @day.update(closed: true)
    assert_equal [ appointment ], @day.conflicting_appointments
    # Simulate a schedule imported before conflict protection existed.
    @day.update_column(:closed, true)
    assert appointment.update(notes: "Keep existing arrangement")
    assert_not appointment.update(starts_at: appointment.starts_at + 1.hour)
  end
  private

  def booking(hour, minute = 0)
    Appointment.new(stylist: @stylist, client: @client, service: "Cut & finish",
      starts_at: Time.zone.local(2030, 1, 7, hour, minute), duration_minutes: 60)
  end
end
