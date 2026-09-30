require "application_system_test_case"

class BookingTest < ApplicationSystemTestCase
  test "books an existing client with one service at a typed time, from the calendar" do
    travel_to Time.zone.parse("2026-10-01 08:00") do
      visit root_path
      click_on "+ New appointment"

      within "dialog" do
        select "Noah Carter", from: "Client"
        select "Melissa", from: "Stylist"
        select "Blowout", from: "Service"
        fill_in "Time", with: "2026-10-01T14:00"
        click_on "Book appointment"
      end

      assert_no_selector "dialog"
      assert_text "Booked. Noah Carter is in with Melissa at 2:00."

      within "#stylist-column-#{stylists(:melissa).id}" do
        assert_text "Noah Carter"
        assert_text "Blowout"
      end
    end
  end

  test "Never mind closes the new appointment dialog without booking anything" do
    visit root_path
    click_on "+ New appointment"
    assert_selector "dialog"

    click_on "Never mind"

    assert_no_selector "dialog"
    assert_text "The appointment book."
  end
end
