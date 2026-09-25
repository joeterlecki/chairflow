class CalendarController < ApplicationController
  def index
    @date = (Date.iso8601((params[:date].presence || params[:week]).to_s) rescue Date.current)
    @week = @date.beginning_of_week
    @view = params[:view] == "day" ? "day" : "week"
    @days = @view == "day" ? [ @date ] : (@week..@week + 6).to_a
    @stylists = Stylist.includes(:working_days, :scheduled_shifts, :time_offs).order(:name)
    @selected_stylist = @stylists.find_by(id: params[:stylist_id])
    @visible_stylists = @selected_stylist ? [ @selected_stylist ] : @stylists.to_a
    appointments = Appointment.includes(:client, :stylist).overlapping(@days.first.in_time_zone, @days.last.next_day.in_time_zone).order(:starts_at)
    appointments = appointments.where(stylist: @selected_stylist) if @selected_stylist
    @appointments = appointments.to_a
    @by_day = @appointments.group_by { |appointment| appointment.starts_at.to_date }
    @by_lane = @appointments.group_by { |appointment| [ appointment.starts_at.to_date, appointment.stylist_id ] }
    @default_duration = Service.default&.default_duration || 60
    @grid = CalendarGrid.new(days: @days, stylists: @visible_stylists, appointments: @appointments)
  end
end
