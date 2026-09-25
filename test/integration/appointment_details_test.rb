require "test_helper"

class AppointmentDetailsTest < ActionDispatch::IntegrationTest
  setup do
    @stylist = Stylist.create!(name: "Melissa")
    @client = Client.create!(name: "Morgan", email: "morgan@example.com", phone: "+1 212 555 0123", preferred_stylist: @stylist)
    @appointment = Appointment.create!(stylist: @stylist, client: @client, service: "Cut & finish",
      starts_at: Time.zone.local(2030, 1, 7, 10), duration_minutes: 60, notes: "Keep the length.\n<script>alert('no')</script>")
  end

  test "calendar booking links target the details frame rather than editing" do
    get root_path(view: "day", date: "2030-01-07")
    assert_select "a.appointment-card[data-turbo-frame=booking_details][aria-haspopup=dialog][href^='#{appointment_path(@appointment)}']"
  end

  test "frame response shows read-only details with an explicit edit action" do
    get appointment_path(@appointment, calendar_view: "day", stylist_id: @stylist.id), headers: { "Turbo-Frame" => "booking_details" }
    assert_response :success
    assert_select "turbo-frame#booking_details dialog[aria-labelledby=booking-details-title]"
    assert_select "#booking-details-title", text: "Morgan"
    assert_select "section[aria-label='Appointment schedule']", text: /10:00 AM.*11:00 AM.*60 minutes/m
    assert_select "a[href='mailto:morgan@example.com']"
    assert_select "a[href='tel:+12125550123']"
    assert_select "dd", text: "Melissa", count: 2
    assert_select "a[data-turbo-frame=_top][href='#{edit_appointment_path(@appointment, calendar_view: 'day', stylist_id: @stylist.id)}']", text: "Edit appointment"
    assert_select "form", count: 0
    assert_select "script", text: /alert/, count: 0
    assert_includes response.body, "&lt;script&gt;"
  end

  test "direct URL has a full-page fallback and handles missing details" do
    @client.update!(email: nil, phone: nil, preferred_stylist: nil)
    @appointment.update!(notes: nil)
    get appointment_path(@appointment, calendar_view: "day")
    assert_response :success
    assert_select "title", text: "Appointment details · Chairflow"
    assert_select "dialog", count: 0
    assert_select "dd", text: "No preference"
    assert_select "span", text: "Not provided", count: 2
    assert_select "p", text: "Nothing noted for this visit."
    assert_select "a[href='#{root_path(view: 'day', date: '2030-01-07')}']", text: "Back to calendar"
  end

  test "details are protected by authentication" do
    delete logout_path
    get appointment_path(@appointment), headers: { "Turbo-Frame" => "booking_details" }
    assert_redirected_to login_path
  end
end
