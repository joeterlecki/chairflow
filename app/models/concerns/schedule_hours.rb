module ScheduleHours
  extend ActiveSupport::Concern
  TIME_FORMAT = /\A(?:[01]\d|2[0-3]):[0-5]\d\z/
  FIELDS = %w[closed opens_at closes_at break_starts_at break_ends_at].freeze

  included do
    validates :opens_at, :closes_at, format: { with: TIME_FORMAT }
    validates :break_starts_at, :break_ends_at, format: { with: TIME_FORMAT }, allow_blank: true
    validate :valid_intervals
  end

  def at(date, value)
    hour, minute = value.split(":").map(&:to_i)
    Time.zone.local(date.year, date.month, date.day, hour, minute)
  end

  def permits?(from, to)
    return false if closed? || from.to_date != to.to_date
    from >= at(from.to_date, opens_at) && to <= at(from.to_date, closes_at) && !on_break?(from, to)
  end

  def on_break?(from, to)
    break_starts_at.present? && break_ends_at.present? && from < at(from.to_date, break_ends_at) && to > at(from.to_date, break_starts_at)
  end

  private

  def valid_intervals
    return if closed? || errors.any?
    errors.add(:closes_at, "must be after opening time") if closes_at <= opens_at
    if break_starts_at.present? != break_ends_at.present?
      errors.add(:base, "Enter both break times, or leave both blank")
    elsif break_starts_at.present? && !(opens_at <= break_starts_at && break_starts_at < break_ends_at && break_ends_at <= closes_at)
      errors.add(:base, "Break must start and finish within working hours, with its end after its start")
    end
  end
end
