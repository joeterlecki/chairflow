require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  def starts_at
    Time.zone.parse("2026-10-05 10:00")
  end

  test "derives ends_at from a single service" do
    appointment = Appointment.new(client: clients(:ava), stylist: stylists(:melissa), starts_at: starts_at)
    appointment.appointment_services.build(service: services(:cut_and_finish), position: 1, duration_minutes: 45)

    assert appointment.valid?
    assert_equal starts_at + 45.minutes, appointment.ends_at
  end

  test "derives ends_at from several services" do
    appointment = Appointment.new(client: clients(:ava), stylist: stylists(:melissa), starts_at: starts_at)
    appointment.appointment_services.build(service: services(:cut_and_finish), position: 1, duration_minutes: 45)
    appointment.appointment_services.build(service: services(:blowout), position: 2, duration_minutes: 30)

    assert appointment.valid?
    assert_equal starts_at + 75.minutes, appointment.ends_at
  end

  test "requires at least one service" do
    appointment = Appointment.new(client: clients(:ava), stylist: stylists(:melissa), starts_at: starts_at)

    assert_not appointment.valid?
    assert_includes appointment.errors[:base], "Choose at least one service."
  end

  test "defaults status to booked" do
    appointment = Appointment.new(client: clients(:ava), stylist: stylists(:melissa), starts_at: starts_at)

    assert appointment.booked?
  end

  test "status can be cancelled" do
    appointment = appointments(:ava_visit)
    appointment.cancelled!

    assert appointment.cancelled?
  end
end
