require "test_helper"

class CalendarGridTest < ActionDispatch::IntegrationTest
  setup do
    @stylist = Stylist.create!(name: "Alex")
    @stylist.working_days.find_by!(weekday: 1).update!(opens_at: "08:30", closes_at: "19:00", break_starts_at: "12:00", break_ends_at: "13:00")
    @booking = Appointment.create!(stylist: @stylist, client: Client.create!(name: "Taylor"), service: "Cut & finish", starts_at: Time.zone.local(2030, 1, 7, 10), duration_minutes: 60)
  end

  test "day grid includes configured hours, breaks, and only free booking links" do
    get root_path(view: "day", date: "2030-01-07")
    assert_response :success
    assert_select ".day-column", count: 1
    assert_select ".hour-label", text: "8:00 AM"
    assert_select ".hour-label", text: "6:00 PM"
    assert_select ".break-block", text: "Break"
    assert_select "a[aria-label='Book Alex, January 7 at 10:00 AM, 60 minutes']", count: 0
    assert_select "a[aria-label='Book Alex, January 7 at 12:00 PM, 60 minutes']", count: 0
    assert_select "a[aria-label='Book Alex, January 7 at 11:00 AM, 60 minutes']"
    assert_select "a[aria-label='Book Alex, January 7 at 11:45 AM, 15 minutes']"
    assert_select "a[aria-label='Next day'][href*='2030-01-08']"
  end

  test "slot prefills are validated and saving returns to selected day" do
    get new_appointment_path(date: "2030-01-07", time: "11:45", stylist_id: @stylist.id, duration_minutes: 15, calendar_view: "day")
    assert_select "input[name='appointment[starts_at]'][value^='2030-01-07T11:45']"
    assert_select "select[name='appointment[duration_minutes]'] option[selected][value='15']"
    post appointments_path, params: { calendar_view: "day", stylist_id: @stylist.id, appointment: {
      stylist_id: @stylist.id, client_id: @booking.client_id, service: "Consultation", starts_at: "2030-01-07T11:45", duration_minutes: 15
    } }
    assert_redirected_to root_path(view: "day", date: "2030-01-07", stylist_id: @stylist.id)
    get new_appointment_path(date: "2030-01-07", time: "99:00", duration_minutes: -1)
    assert_response :success
    assert_select "input[name='appointment[starts_at]'][value^='2030-01-07T09:00']"
  end

  test "day off has no free slots but still shows an existing appointment" do
    # Legacy data may predate schedule conflict protection.
    @stylist.working_days.find_by!(weekday: 1).update_column(:closed, true)
    get root_path(view: "day", date: "2030-01-07")
    assert_select ".day-off-label", text: "Day off"
    assert_select ".calendar-open-slot", count: 0
    assert_select ".appointment-card", text: /Taylor/
  end
end
