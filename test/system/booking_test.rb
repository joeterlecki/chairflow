require "application_system_test_case"

class BookingTest < ApplicationSystemTestCase
  test "books an existing client with one service at a typed time, from the calendar" do
    travel_to Time.zone.parse("2026-10-01 08:00") do
      visit root_path
      click_on "+ New appointment"

      within "dialog" do
        select "Noah Carter", from: "Client"
        select "Melissa", from: "Stylist"
        fill_in "Service", with: "Blowout"
        fill_in "Minutes", with: "30"
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

  test "books several services with a running total" do
    travel_to Time.zone.parse("2026-10-01 08:00") do
      visit root_path
      click_on "+ New appointment"

      within "dialog" do
        select "Noah Carter", from: "Client"
        select "Melissa", from: "Stylist"

        within all("[data-service-lines-target='row']").first do
          fill_in "Service", with: "Cut & finish"
          fill_in "Minutes", with: "45"
        end
        assert_text "45 min"

        click_on "+ Add a service"
        within all("[data-service-lines-target='row']").last do
          fill_in "Service", with: "Gloss"
          fill_in "Minutes", with: "30"
        end
        assert_text "75 min"

        fill_in "Time", with: "2026-10-01T14:00"
        click_on "Book appointment"
      end

      within "#stylist-column-#{stylists(:melissa).id}" do
        assert_text "Noah Carter"
        assert_text "Cut & finish and Gloss"
      end
    end
  end

  test "removing a service row updates the running total" do
    visit root_path
    click_on "+ New appointment"

    within "dialog" do
      within all("[data-service-lines-target='row']").first do
        fill_in "Service", with: "Cut & finish"
        fill_in "Minutes", with: "45"
      end

      click_on "+ Add a service"
      within all("[data-service-lines-target='row']").last do
        fill_in "Service", with: "Gloss"
        fill_in "Minutes", with: "30"
      end
      assert_text "75 min"

      within all("[data-service-lines-target='row']").last do
        click_on "Remove"
      end
      assert_text "45 min"
    end
  end

  test "typing a brand-new service name creates it" do
    travel_to Time.zone.parse("2026-10-01 08:00") do
      assert_not Service.exists?(name: "Deep condition")

      visit root_path
      click_on "+ New appointment"

      within "dialog" do
        select "Noah Carter", from: "Client"
        select "Melissa", from: "Stylist"
        fill_in "Service", with: "Deep condition"
        fill_in "Minutes", with: "20"
        fill_in "Time", with: "2026-10-01T15:00"
        click_on "Book appointment"
      end

      assert_text "Booked. Noah Carter is in with Melissa at 3:00."
      assert Service.exists?(name: "Deep condition")

      within "#stylist-column-#{stylists(:melissa).id}" do
        assert_text "Deep condition"
      end
    end
  end

  test "typing an existing service name in a different case reuses it, not a duplicate" do
    travel_to Time.zone.parse("2026-10-01 08:00") do
      count_before = Service.count

      visit root_path
      click_on "+ New appointment"

      within "dialog" do
        select "Noah Carter", from: "Client"
        select "Melissa", from: "Stylist"
        fill_in "Service", with: "cut & finish"
        fill_in "Minutes", with: "45"
        fill_in "Time", with: "2026-10-01T16:00"
        click_on "Book appointment"
      end

      assert_equal count_before, Service.count
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
