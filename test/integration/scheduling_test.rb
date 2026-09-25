require "test_helper"

class SchedulingTest < ActionDispatch::IntegrationTest
  setup do
    @stylist = Stylist.create!(name: "Alex")
    @client = Client.create!(name: "Taylor")
    @start = Time.zone.local(2026, 9, 24, 10)
  end

  test "calendar displays seven days and navigates and filters in a turbo frame" do
    create_booking
    other = Stylist.create!(name: "Jamie", color: "clay")
    get root_path(week: "2026-09-24")
    assert_response :success
    assert_select ".day-column", count: 7
    assert_select ".appointment-card", text: /Taylor/
    assert_select "a[aria-label='Next week'][href*='2026-09-28']"

    get root_path(week: "2026-09-21", stylist_id: other.id), headers: { "Turbo-Frame" => "calendar" }
    assert_response :success
    assert_select "turbo-frame#calendar"
    assert_select "turbo-frame#calendar a[data-turbo-frame='_top'][href*='stylist_id=#{other.id}']", text: "+ New appointment"
    assert_select ".appointment-card", count: 0

    get root_path(week: "2026-09-28")
    assert_select ".appointment-card", count: 0
    get root_path(week: "invalid")
    assert_response :success
  end

  test "books a new client, edits and cancels their appointment" do
    get new_appointment_path(date: "2026-09-24", stylist_id: @stylist.id)
    assert_response :success
    assert_select "input[type='datetime-local']"

    assert_difference [ "Appointment.count", "Client.count" ], 1 do
      post appointments_path, params: { appointment: booking_params.merge(client_id: "", new_client_name: "  Morgan Lee  ") }
    end
    booking = Appointment.order(:id).last
    assert_equal "Morgan Lee", booking.client.name
    assert_redirected_to root_path(week: "2026-09-21")
    follow_redirect!
    assert_select ".appointment-card", text: /Morgan Lee/

    get edit_appointment_path(booking)
    assert_response :success
    patch appointment_path(booking), params: { appointment: booking_params.merge(client_id: booking.client_id, starts_at: "2026-09-25T14:00", duration_minutes: "90") }
    assert_response :see_other
    assert_equal 90, booking.reload.duration_minutes
    assert_equal 14, booking.starts_at.hour

    assert_difference "Appointment.count", -1 do
      delete appointment_path(booking)
    end
    assert_response :see_other
  end

  test "conflicting booking returns errors and does not leave an orphan client" do
    create_booking
    assert_no_difference [ "Appointment.count", "Client.count" ] do
      post appointments_path, params: { appointment: booking_params.merge(new_client_name: "New person") }
    end
    assert_response :unprocessable_entity
    assert_select "[role='alert']", text: /already has an appointment/
    assert_select "input[name='appointment[new_client_name]'][value='New person']"
  end

  private

  def booking_params
    { stylist_id: @stylist.id, client_id: @client.id, service: "Cut & finish", starts_at: "2026-09-24T10:00", duration_minutes: "60" }
  end

  def create_booking
    Appointment.create!(stylist: @stylist, client: @client, service: "Cut & finish", starts_at: @start, duration_minutes: 60)
  end
end
