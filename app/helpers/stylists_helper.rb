module StylistsHelper
  def coverage_hours(schedule, date)
    return 0 unless schedule && !schedule.closed?
    minutes = (schedule.at(date, schedule.closes_at) - schedule.at(date, schedule.opens_at)) / 60
    minutes -= (schedule.at(date, schedule.break_ends_at) - schedule.at(date, schedule.break_starts_at)) / 60 if schedule.break_starts_at.present?
    minutes / 60.0
  end

  def schedule_source(schedule)
    case schedule
    when TimeOff then "Time off"
    when ScheduledShift then "One-day change"
    else "Usual hours"
    end
  end
end
