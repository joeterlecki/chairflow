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

  test "moves to tomorrow, then back to today" do
    travel_to Time.zone.parse("2026-10-01 08:00") do # a Thursday
      visit root_path
      assert_text "Thursday, October 1"

      click_on "→"
      assert_text "Friday, October 2"

      click_on "Today"
      assert_text "Thursday, October 1"

      click_on "←"
      assert_text "Wednesday, September 30"
    end
  end

  test "a closed day shows a gentle message instead of the grid" do
    travel_to Time.zone.parse("2026-10-05 08:00") do # a Monday, closed in fixtures
      visit root_path

      assert_text "We're closed today. A well-earned rest."
      assert_no_selector "#stylist-column-#{stylists(:melissa).id}"
    end
  end
end
