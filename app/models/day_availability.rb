class DayAvailability
  attr_reader :stylist, :starts_at, :duration, :bookings, :working_day

  def initialize(stylist:, starts_at:, duration:, excluding_id: nil)
    @stylist = stylist
    @starts_at = starts_at
    @duration = duration
    @working_day = stylist&.schedule_for(starts_at.to_date)
    @bookings = if stylist
      stylist.appointments.includes(:client).where.not(id: excluding_id.presence)
        .overlapping(starts_at.beginning_of_day, starts_at.next_day.beginning_of_day).order(:starts_at).to_a
    else
      []
    end
  end

  def conflicts_at(time)
    bookings.select { |booking| booking.starts_at < time + duration.minutes && booking.ends_at > time }
  end

  def slots
    return [] unless working_day && !working_day.closed?
    opening = working_day.at(starts_at.to_date, working_day.opens_at)
    closing = working_day.at(starts_at.to_date, working_day.closes_at)
    (0..((closing - opening - duration.minutes) / 15.minutes).floor).map { |index| opening + index * 15.minutes }
  end

  def open_slots
    slots.select { |time| unavailable_reason(time).nil? }
  end

  def unavailable_reason(time = starts_at)
    return "Time off" if working_day.is_a?(TimeOff)
    return "Day off" unless working_day && !working_day.closed?
    return "Time conflict" if conflicts_at(time).any?
    return "During a break" if working_day.on_break?(time, time + duration.minutes)
    return "Outside working hours" unless working_day.permits?(time, time + duration.minutes)
    nil
  end
end
