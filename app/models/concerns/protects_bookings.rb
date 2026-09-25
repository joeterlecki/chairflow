module ProtectsBookings
  extend ActiveSupport::Concern

  def conflicting_appointments
    @conflicting_appointments || []
  end

  private

  def record_conflicts(bookings)
    @conflicting_appointments = bookings
    if bookings.any?
      errors.add(:base, "This change conflicts with #{bookings.size} existing appointment(s). Reschedule those bookings before changing coverage.")
    end
  end
end
