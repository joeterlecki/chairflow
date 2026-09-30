require "test_helper"

class ApplicationTest < ActiveSupport::TestCase
  test "runs in the salon's time zone" do
    assert_equal "America/New_York", Time.zone.name
  end
end
