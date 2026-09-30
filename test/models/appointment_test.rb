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

  test "back-to-back appointments for the same stylist are allowed" do
    existing = appointments(:ava_visit)
    appointment = Appointment.new(client: clients(:noah), stylist: existing.stylist, starts_at: existing.ends_at)
    appointment.appointment_services.build(service: services(:blowout), position: 1, duration_minutes: 30)

    assert appointment.valid?
  end

  test "overlapping appointments for the same stylist are invalid" do
    existing = appointments(:ava_visit)
    appointment = Appointment.new(
      client: clients(:noah), stylist: existing.stylist, starts_at: existing.starts_at + 15.minutes
    )
    appointment.appointment_services.build(service: services(:blowout), position: 1, duration_minutes: 30)

    assert_not appointment.valid?
    assert_includes appointment.errors[:starts_at], "#{existing.stylist.name} is with #{existing.client.name} until #{existing.ends_at.strftime('%-l:%M %p')}."
  end

  test "cancelled appointments don't block the same time" do
    existing = appointments(:ava_visit)
    existing.cancelled!
    appointment = Appointment.new(
      client: clients(:noah), stylist: existing.stylist, starts_at: existing.starts_at + 15.minutes
    )
    appointment.appointment_services.build(service: services(:blowout), position: 1, duration_minutes: 30)

    assert appointment.valid?
  end

  test "editing an appointment doesn't clash with itself" do
    appointment = appointments(:ava_visit)
    appointment.notes = "Running a few minutes late"

    assert appointment.valid?
  end

  test "removing a service shortens ends_at and can free a clash" do
    existing = appointments(:ava_visit) # melissa, 09:00-09:45 (cut & finish only)
    blowout_line = existing.appointment_services.create!(service: services(:blowout), position: 2, duration_minutes: 30)
    existing.save!
    assert_equal existing.starts_at + 75.minutes, existing.ends_at

    clashing = Appointment.new(client: clients(:noah), stylist: existing.stylist, starts_at: existing.starts_at + 50.minutes)
    clashing.appointment_services.build(service: services(:blowout), position: 1, duration_minutes: 30)
    assert_not clashing.valid?

    existing.appointment_services_attributes = [ { id: blowout_line.id, _destroy: true } ]
    existing.save!
    assert_equal existing.starts_at + 45.minutes, existing.ends_at

    assert clashing.valid?
  end
end
