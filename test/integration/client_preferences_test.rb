require "test_helper"

class ClientPreferencesTest < ActionDispatch::IntegrationTest
  setup do
    @alex = Stylist.create!(name: "Alex")
    @jamie = Stylist.create!(name: "Jamie")
  end

  test "new inline client defaults to booking stylist" do
    book_client
    assert_response :see_other
    assert_equal @alex, Client.find_by!(name: "Morgan").preferred_stylist
  end

  test "inline client can explicitly choose no preference or another stylist" do
    book_client(new_client_preferred_stylist_id: "")
    assert_response :see_other
    assert_nil Client.find_by!(name: "Morgan").preferred_stylist
    book_client(new_client_name: "Taylor", starts_at: "2030-01-07T11:00", new_client_preferred_stylist_id: @jamie.id)
    assert_response :see_other
    assert_equal @jamie, Client.find_by!(name: "Taylor").preferred_stylist
  end

  test "client editor can set and clear preference and later bookings preserve it" do
    client = Client.create!(name: "Morgan", preferred_stylist: @alex)
    patch client_path(client), params: { client: { preferred_stylist_id: @jamie.id } }
    assert_equal @jamie, client.reload.preferred_stylist
    patch client_path(client), params: { client: { preferred_stylist_id: "" } }
    assert_response :see_other
    assert_nil client.reload.preferred_stylist
    book_client(client_id: client.id, new_client_name: "")
    assert_response :see_other
    assert_nil client.reload.preferred_stylist
  end

  test "invalid stylist returns form errors without saving client or appointment" do
    assert_no_difference [ "Client.count", "Appointment.count" ] do
      book_client(new_client_preferred_stylist_id: -1)
    end
    assert_response :unprocessable_entity
    assert_not Client.new(name: "Morgan", preferred_stylist_id: -1).valid?
  end

  test "failed booking retains explicit no preference" do
    book_client(starts_at: "2030-01-07T23:30", new_client_preferred_stylist_id: "")
    assert_response :unprocessable_entity
    assert_select "select[name='appointment[new_client_preferred_stylist_id]'] option[selected][value='']", text: "No preference"
  end

  private

  def book_client(**overrides)
    post appointments_path, params: { appointment: {
      new_client_name: "Morgan", stylist_id: @alex.id, service: "Cut & finish",
      starts_at: "2030-01-07T10:00", duration_minutes: 60
    }.merge(overrides) }
  end
end
