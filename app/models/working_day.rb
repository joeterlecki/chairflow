class WorkingDay < ApplicationRecord
  include ScheduleHours
  include ProtectsBookings
  belongs_to :stylist
  validates :weekday, inclusion: { in: 0..6 }, uniqueness: { scope: :stylist_id }
  validate :protect_future_bookings, on: :update

  private

  def protect_future_bookings
    return if errors.any? || ScheduleHours::FIELDS.none? { |field| will_save_change_to_attribute?(field) }

    bookings = stylist.appointments.includes(:client).where("ends_at > ?", Time.current).order(:starts_at).select do |booking|
      date = booking.starts_at.to_date
      date.wday == weekday && !stylist.schedule_override_for(date) && !permits?(booking.starts_at, booking.ends_at)
    end
    record_conflicts(bookings)
  end
end
