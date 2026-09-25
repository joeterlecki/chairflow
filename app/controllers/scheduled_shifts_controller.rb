class ScheduledShiftsController < ApplicationController
  before_action :load_shift

  def edit
  end

  def update
    if @shift.update(params.expect(scheduled_shift: [ :closed, :opens_at, :closes_at, :break_starts_at, :break_ends_at ]))
      redirect_to team_schedule_path(week: @date.beginning_of_week), notice: "Shift saved for #{@stylist.name} on #{@date.strftime('%b %-d')}.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if !@shift.persisted? || @shift.destroy
      redirect_to team_schedule_path(week: @date.beginning_of_week), notice: "Recurring hours restored for this date.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def load_shift
    @stylist = Stylist.find(params[:stylist_id])
    @date = Date.iso8601(params[:date].to_s)
    @shift = @stylist.scheduled_shifts.find_by(date: @date)
    unless @shift
      recurring = @stylist.working_days.find_by(weekday: @date.wday)
      @shift = @stylist.scheduled_shifts.build((recurring&.attributes || {}).slice(*ScheduleHours::FIELDS).merge(date: @date))
    end
    @time_off = @stylist.time_offs.find { |absence| absence.covers?(@date) }
  rescue Date::Error
    raise ActionController::BadRequest, "Choose a valid shift date"
  end
end
