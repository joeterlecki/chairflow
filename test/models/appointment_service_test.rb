require "test_helper"

class AppointmentServiceTest < ActiveSupport::TestCase
  test "defaults duration_minutes from the service when not given" do
    line = AppointmentService.new(appointment: appointments(:ava_visit), service: services(:blowout), position: 1)

    assert line.valid?
    assert_equal services(:blowout).default_duration_minutes, line.duration_minutes
  end

  test "an explicit duration_minutes overrides the service default" do
    line = AppointmentService.new(
      appointment: appointments(:ava_visit), service: services(:blowout), position: 1, duration_minutes: 20
    )

    assert line.valid?
    assert_equal 20, line.duration_minutes
  end

  test "requires a positive duration_minutes" do
    line = AppointmentService.new(
      appointment: appointments(:ava_visit), service: services(:blowout), position: 1, duration_minutes: 0
    )

    assert_not line.valid?
    assert_includes line.errors[:duration_minutes], "must be greater than 0"
  end

  test "requires a position" do
    line = AppointmentService.new(appointment: appointments(:ava_visit), service: services(:blowout))

    assert_not line.valid?
    assert_includes line.errors[:position], "can't be blank"
  end
end
