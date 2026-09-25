# Shared wall-clock geometry keeps the same time aligned across all stylist lanes.
class CalendarGrid
  PIXELS_PER_MINUTE = 1.6
  attr_reader :first_minute, :last_minute

  def initialize(days:, stylists:, appointments:)
    schedules = stylists.flat_map { |stylist| days.filter_map { |date| stylist.schedule_for(date) } }.reject(&:closed?)
    starts = schedules.map { |day| minutes(day.opens_at) } + appointments.map { |booking| minutes(booking.starts_at) }
    ends = schedules.map { |day| minutes(day.closes_at) } + appointments.map { |booking| minutes(booking.ends_at) }
    @first_minute = (starts.min || 540) / 60 * 60
    @last_minute = ((ends.max || 1080) / 60.0).ceil * 60
  end

  def minutes(value)
    return value.hour * 60 + value.min if value.respond_to?(:hour)
    hour, minute = value.split(":").map(&:to_i)
    hour * 60 + minute
  end

  def height
    (last_minute - first_minute) * PIXELS_PER_MINUTE
  end

  def position(from, to)
    "top: #{(minutes(from) - first_minute) * PIXELS_PER_MINUTE}px; height: #{(minutes(to) - minutes(from)) * PIXELS_PER_MINUTE}px;"
  end

  def label(minute)
    hour = (minute / 60) % 24
    "#{hour % 12 == 0 ? 12 : hour % 12}:#{format('%02d', minute % 60)} #{hour < 12 ? 'AM' : 'PM'}"
  end

  def open_starts(date, schedule, bookings, default_duration)
    return [] unless schedule && !schedule.closed?
    (first_minute...last_minute).step(15).filter_map do |minute|
      time = Time.zone.local(date.year, date.month, date.day, minute / 60, minute % 60)
      duration = Appointment::DURATIONS.select { |value| value <= default_duration }.reverse.find do |value|
        finish = time + value.minutes
        schedule.permits?(time, finish) && bookings.none? { |booking| booking.starts_at < finish && booking.ends_at > time }
      end
      [ time, duration ] if duration
    end
  end
end
