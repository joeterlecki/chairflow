require "application_system_test_case"

class CalendarTest < ApplicationSystemTestCase
  test "visiting the root page shows the appointment book" do
    visit root_path

    assert_text "The appointment book."
  end

  test "shows a fixture appointment under the right stylist" do
    travel_to Time.zone.parse("2026-10-01 08:00") do # a Thursday; ava_visit is that day
      visit root_path

      within "#stylist-column-#{stylists(:melissa).id}" do
        assert_text "Ava Thompson"
        assert_text "Cut & finish"
      end

      within "#stylist-column-#{stylists(:devon).id}" do
        assert_no_text "Ava Thompson"
      end
    end
  end
end
