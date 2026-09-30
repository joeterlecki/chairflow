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

  # Row indices for each hour boundary strictly inside the window (never at the
  # very top or bottom edge, which the column's own border already marks).
  def day_hour_marks(window)
    (4...day_slot_count(window)).step(4).map { |slot| slot + 1 }
  end

  # The row "now" falls in, snapped to the same 15-minute grid as everything
  # else -- or nil if the window isn't showing today (window.cover? is false
  # for any other date, or for today outside salon hours), so there's nothing
  # to draw.
  def day_now_row(window)
    day_row_for(window, Time.current) if window.cover?(Time.current)
  end
end
