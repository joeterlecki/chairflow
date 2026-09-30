module CalendarHelper
  DAY_GRID_STEP = 15.minutes

  def day_slot_count(window)
    ((window.end - window.begin) / DAY_GRID_STEP).to_i
  end

  def day_row_for(window, time)
    ((time - window.begin) / DAY_GRID_STEP).to_i + 1
  end

  def day_span_for(duration)
    (duration / DAY_GRID_STEP).ceil
  end
end
