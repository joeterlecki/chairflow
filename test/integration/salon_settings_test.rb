require "test_helper"

class SalonSettingsTest < ActionDispatch::IntegrationTest
  test "weekly schedule update is atomic when one break is invalid" do
    stylist = Stylist.create!(name: "Alex")
    monday = stylist.working_days.find_by!(weekday: 1)
    tuesday = stylist.working_days.find_by!(weekday: 2)
    patch stylist_path(stylist), params: { stylist: { working_days_attributes: {
      "0" => { id: monday.id, opens_at: "10:00" },
      "1" => { id: tuesday.id, break_starts_at: "12:00", break_ends_at: "" }
    } } }
    assert_response :unprocessable_entity
    assert_select "[role=alert]", text: /both break times/
    assert_equal "09:00", monday.reload.opens_at
  end

  test "service default is persisted and used when duration is omitted" do
    service = services(:blowout)
    patch service_path(service), params: { service: { default_duration: 45 } }
    assert_response :see_other
    assert_equal 45, service.reload.default_duration
    stylist = Stylist.create!(name: "Alex")
    post appointments_path, params: { appointment: {
      service: service.name, stylist_id: stylist.id, starts_at: "2030-01-07T10:00",
      new_client_name: "Morgan", new_client_email: " MORGAN@example.com ", new_client_phone: "+1 212 555 0123"
    } }
    assert_response :see_other
    appointment = Appointment.order(:id).last
    assert_equal 45, appointment.duration_minutes
    assert_equal "morgan@example.com", appointment.client.email
    assert_equal "+1 212 555 0123", appointment.client.phone
    patch service_path(service), params: { service: { default_duration: 90 } }
    assert_equal 45, appointment.reload.duration_minutes
  end

  test "invalid inline contact rolls back the entire booking" do
    stylist = Stylist.create!(name: "Alex")
    assert_no_difference [ "Appointment.count", "Client.count" ] do
      post appointments_path, params: { appointment: {
        service: "Cut & finish", duration_minutes: 60, stylist_id: stylist.id, starts_at: "2030-01-07T10:00",
        new_client_name: "Morgan", new_client_email: "invalid"
      } }
    end
    assert_response :unprocessable_entity
    assert_select "input[name='appointment[new_client_email]'][value=invalid]"
  end

  test "client contacts are optional, normalized, searchable and validated" do
    post clients_path, params: { client: { name: " Casey ", email: " CASEY@example.com ", phone: "+44 20 7946 0000" } }
    client = Client.order(:id).last
    assert_response :see_other
    assert_equal "casey@example.com", client.email
    get clients_path(q: "7946")
    assert_select "h2", text: "Casey"
    patch client_path(client), params: { client: { email: "invalid", phone: "not a number" } }
    assert_response :unprocessable_entity
    assert_select "[role=alert]", text: /Email is invalid/
    assert_equal "casey@example.com", client.reload.email
    patch client_path(client), params: { client: { email: "", phone: "" } }
    assert_response :see_other
    assert_nil client.reload.email
    assert_nil client.phone
  end
end
