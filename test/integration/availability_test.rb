require "test_helper"

class AvailabilityTest < ActionDispatch::IntegrationTest
  setup do
    @stylist = Stylist.create!(name: "Alex")
    @booking = Appointment.create!(stylist: @stylist, client: Client.create!(name: "Taylor"),
      service: "Cut & finish", starts_at: Time.zone.local(2026, 9, 24, 10), duration_minutes: 60)
  end

  test "shows conflicts and offers only times that fit the full duration" do
    request_availability(appointment_id: "")
    assert_response :success
    assert_select "turbo-frame#day_availability"
    assert_select "[role=status]", text: /Time conflict.*Taylor/m
    assert_select "button[data-time='2026-09-24T09:00']"
    assert_select "button[data-time='2026-09-24T09:15']", count: 0
    assert_select "button[data-time='2026-09-24T10:00']", count: 0
    assert_select "button[data-time='2026-09-24T11:00']"
    assert_select "button[data-time='2026-09-24T17:00']"
    assert_select "button[data-time='2026-09-24T17:15']", count: 0

    request_availability(duration_minutes: 90)
    assert_select "button[data-time='2026-09-24T09:00']", count: 0
    assert_select "button[data-time='2026-09-24T16:30']"
    assert_select "button[data-time='2026-09-24T16:45']", count: 0
  end

  test "editing excludes itself but still detects another booking" do
    request_availability(appointment_id: @booking.id)
    assert_select "[role=status]", text: /No booking conflicts/
    assert_select "button[data-time='2026-09-24T10:00'][aria-pressed=true]"

    Appointment.create!(stylist: @stylist, client: @booking.client, service: "Blowout",
      starts_at: @booking.ends_at, duration_minutes: 60)
    request_availability(appointment_id: @booking.id, duration_minutes: 90)
    assert_select "[role=status]", text: /Time conflict/
    assert_select "button[data-time='2026-09-24T10:00']", count: 0
  end

  test "changing day or stylist changes availability" do
    request_availability(starts_at: "2026-09-25T10:00")
    assert_select "[role=status]", text: /No booking conflicts/
    assert_select "button[data-time='2026-09-25T10:00']"

    request_availability(stylist_id: Stylist.create!(name: "Sam").id)
    assert_select "[role=status]", text: /No booking conflicts/
    assert_select "button[data-time='2026-09-24T10:00']"
  end

  test "handles missing stylist and malformed inputs" do
    request_availability(stylist_id: "")
    assert_response :success
    assert_select "turbo-frame", text: /Choose a stylist/
    assert_select ".time-slot", count: 0

    request_availability(starts_at: "not-a-date")
    assert_response :unprocessable_entity
    request_availability(duration_minutes: "-15")
    assert_response :unprocessable_entity
  end

  test "new and edit forms render the day planner with the correct date" do
    get new_appointment_path(date: "2026-09-24", stylist_id: @stylist.id)
    assert_response :success
    assert_select "turbo-frame#day_availability", text: /Thursday, Sep 24/
    assert_select "[data-availability-target=start][value^='2026-09-24T09:00']"

    get edit_appointment_path(@booking)
    assert_response :success
    assert_select "turbo-frame#day_availability [role=status]", text: /No booking conflicts/
    assert_select "button[data-time='2026-09-24T10:00'][aria-pressed=true]"
  end

  private

  def request_availability(**overrides)
    get availability_appointments_path, params: { stylist_id: @stylist.id, starts_at: "2026-09-24T10:00", duration_minutes: 60 }.merge(overrides),
      headers: { "Turbo-Frame" => "day_availability" }
  end
end
