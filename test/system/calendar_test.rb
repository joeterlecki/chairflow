require "application_system_test_case"

class CalendarTest < ApplicationSystemTestCase
  test "visiting the root page shows the appointment book" do
    visit root_path

    assert_text "The appointment book."
  end
end
