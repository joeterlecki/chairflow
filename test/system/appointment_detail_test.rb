require "application_system_test_case"

class AppointmentDetailTest < ApplicationSystemTestCase
  test "opening a card shows the client, services, and time" do
    travel_to Time.zone.parse("2026-10-01 08:00") do # a Thursday; ava_visit is that day
      visit root_path

      within "#stylist-column-#{stylists(:melissa).id}" do
        click_on "Ava Thompson"
      end

      within "dialog" do
        assert_text "Ava Thompson"
        assert_text "Cut & finish"
        assert_text "9:00"
        assert_text "Melissa"
      end
    end
  end
end
