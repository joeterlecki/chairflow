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

  test "picking a service prefills its default duration" do
    visit root_path
    click_on "+ New appointment"

    within "dialog" do
      select "Cut & finish", from: "Service"
      assert_field "Minutes", with: services(:cut_and_finish).default_duration_minutes.to_s
      assert_text "#{services(:cut_and_finish).default_duration_minutes} min"
    end
  end

  test "books several services and sees the combined end time" do
    travel_to Time.zone.parse("2026-10-01 08:00") do
      visit root_path
      click_on "+ New appointment"

      within "dialog" do
        select "Noah Carter", from: "Client"
        select "Melissa", from: "Stylist"

        within all("[data-service-lines-target='row']").first do
          select "Cut & finish", from: "Service"
        end
        assert_text "45 min"

        click_on "+ Add a service"
        within all("[data-service-lines-target='row']").last do
          select "Blowout", from: "Service"
        end
        assert_text "75 min"

        fill_in "Time", with: "2026-10-01T14:00"
        click_on "Book appointment"
      end

      within "#stylist-column-#{stylists(:melissa).id}" do
        assert_text "Noah Carter"
        click_on "Noah Carter"
      end

      within "dialog" do
        assert_text "2:00"
        assert_text "3:15 PM"
      end
    end
  end

  test "removing a service row updates the running total" do
    visit root_path
    click_on "+ New appointment"

    within "dialog" do
      within all("[data-service-lines-target='row']").first do
        select "Cut & finish", from: "Service"
      end
      assert_text "45 min"

      click_on "+ Add a service"
      within all("[data-service-lines-target='row']").last do
        select "Blowout", from: "Service"
      end
      assert_text "75 min"

      within all("[data-service-lines-target='row']").last do
        click_on "Remove"
      end
      assert_text "45 min"
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
