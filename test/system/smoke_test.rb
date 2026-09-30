require "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  test "the app boots and serves a page in a real browser" do
    visit rails_health_check_path

    assert_selector "body"
  end
end
