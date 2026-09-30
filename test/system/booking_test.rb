require "application_system_test_case"

class BookingTest < ApplicationSystemTestCase
  test "books an existing client with one service at a typed time" do
    travel_to Time.zone.parse("2026-10-01 08:00") do
      visit new_appointment_path

      select "Noah Carter", from: "Client"
      select "Melissa", from: "Stylist"
      select "Blowout", from: "Service"
      fill_in "Time", with: "2026-10-01T14:00"
      click_on "Book appointment"

      assert_text "Booked. Noah Carter is in with Melissa at 2:00."

      within "#stylist-column-#{stylists(:melissa).id}" do
        assert_text "Noah Carter"
        assert_text "Blowout"
      end
    end
  end
end
