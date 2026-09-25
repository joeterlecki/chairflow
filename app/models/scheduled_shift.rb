class ScheduledShift < ApplicationRecord
  include ScheduleHours
  include ProtectsBookings
  belongs_to :stylist
  validates :date, presence: true, uniqueness: { scope: :stylist_id }
  validate :protect_existing_bookings
  before_destroy :protect_reverting_bookings

  private

  def bookings_on_date
    stylist.appointments.includes(:client).overlapping(date.in_time_zone, date.next_day.in_time_zone).order(:starts_at)
  end

  def protect_existing_bookings
    return if errors.any? || !stylist || !date
    record_conflicts(bookings_on_date.reject { |booking| permits?(booking.starts_at, booking.ends_at) })
  end

  def protect_reverting_bookings
    recurring = stylist.working_days.find { |day| day.weekday == date.wday }
    record_conflicts(bookings_on_date.reject { |booking| recurring&.permits?(booking.starts_at, booking.ends_at) })
    throw :abort if errors.any?
  end
end
