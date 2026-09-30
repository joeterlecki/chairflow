require "test_helper"

class ServiceTest < ActiveSupport::TestCase
  test "active scope excludes inactive services" do
    assert_includes Service.active, services(:cut_and_finish)
    assert_not_includes Service.active, services(:retired)
  end

  test "requires a name" do
    service = Service.new(default_duration_minutes: 30)
    assert_not service.valid?
    assert_includes service.errors[:name], "can't be blank"
  end

  test "requires a positive default duration" do
    service = Service.new(name: "Trim", default_duration_minutes: 0)
    assert_not service.valid?
    assert_includes service.errors[:default_duration_minutes], "must be greater than 0"
  end
end
