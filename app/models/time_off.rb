class TimeOff < ApplicationRecord
  include ProtectsBookings
  belongs_to :stylist
  validates :starts_on, :ends_on, presence: true
  validates :note, length: { maximum: 200 }
  validate :valid_date_range
  validate :protect_existing_bookings

  def covers?(date)
    (starts_on..ends_on).cover?(date)
  end

  def closed?
    true
  end

  def permits?(_from, _to)
    false
  end

  private

  def valid_date_range
    return unless starts_on && ends_on
    errors.add(:ends_on, "must be on or after the start date") if ends_on < starts_on
    if stylist && stylist.time_offs.where.not(id: id).where("starts_on <= ? AND ends_on >= ?", ends_on, starts_on).exists?
      errors.add(:base, "Time off already exists within these dates")
    end
  end

  def protect_existing_bookings
    return if errors.any? || !stylist
    record_conflicts(stylist.appointments.includes(:client).overlapping(starts_on.in_time_zone, ends_on.next_day.in_time_zone).order(:starts_at).to_a)
  end
end
