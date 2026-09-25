module CalendarHelper
  def calendar_path(date: @date, view: @view, stylist_id: @selected_stylist&.id)
    root_path(view: view, week: view == "week" ? date.beginning_of_week : nil, date: view == "day" ? date : nil, stylist_id: stylist_id)
  end

  def back_to_calendar_path(appointment)
    date = appointment.starts_at&.to_date || Date.current
    if params[:calendar_view] == "day"
      root_path(view: "day", date: date, stylist_id: params[:stylist_id])
    else
      root_path(week: date.beginning_of_week, stylist_id: params[:stylist_id], view: params[:calendar_view] == "week" ? "week" : nil)
    end
  end
end
