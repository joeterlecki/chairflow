class SalonDay < ApplicationRecord
  STEP = 15

  validates :wday, inclusion: { in: 0..6 }, uniqueness: true
  validates :opens_minute, :closes_minute, inclusion: { in: 0..(24 * 60 - STEP) }
  validate :closes_after_opens, :on_the_slot_grid

  def self.hours_on(date)
    day = find_by(wday: date.wday)
    day.range_on(date) unless day.nil? || day.closed?
  end

  def self.week_from_monday
    all.sort_by { |day| (day.wday - 1) % 7 }
  end

  def range_on(date)
    wall_clock(date, opens_minute)...wall_clock(date, closes_minute)
  end

  private

  # Sets the local wall clock; never add minutes to midnight (wrong on DST days).
  def wall_clock(date, minute)
    date.in_time_zone.change(hour: minute / 60, min: minute % 60)
  end

  def closes_after_opens
    errors.add(:closes_minute, "needs to be after opening") if closes_minute && opens_minute && closes_minute <= opens_minute
  end

  def on_the_slot_grid
    return if [ opens_minute, closes_minute ].compact.all? { |m| (m % STEP).zero? }

    errors.add(:base, "Times need to be on the quarter hour")
  end
end
