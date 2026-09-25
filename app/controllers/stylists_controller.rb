class StylistsController < ApplicationController
  def index
    @week = (Date.iso8601(params[:week].to_s) rescue Date.current).beginning_of_week
    @days = (@week..@week + 6).to_a
    @stylists = Stylist.includes(:working_days, :scheduled_shifts, :time_offs).order(:name)
    @schedules = @stylists.to_h { |stylist| [ stylist.id, @days.to_h { |date| [ date, stylist.schedule_for(date) ] } ] }
    @bookings = Appointment.includes(:client).overlapping(@week.in_time_zone, (@week + 7).in_time_zone).order(:starts_at).group_by { |booking| [ booking.stylist_id, booking.starts_at.to_date ] }
    @time_offs = TimeOff.includes(:stylist).where("starts_on <= ? AND ends_on >= ?", @week + 6, @week).order(:starts_on)
  end

  def edit
    @stylist = Stylist.find(params[:id])
  end

  def update
    @stylist = Stylist.find(params[:id])
    if @stylist.update(params.expect(stylist: [ working_days_attributes: [ [ :id, :closed, :opens_at, :closes_at, :break_starts_at, :break_ends_at ] ] ]))
      redirect_to team_schedule_path, notice: "Working hours saved. Date-specific shifts and time off stay in place.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
