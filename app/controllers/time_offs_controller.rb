class TimeOffsController < ApplicationController
  before_action :load_stylists, only: %i[new create]

  def new
    date = (Date.iso8601(params[:date].to_s) rescue Date.current)
    @time_off = TimeOff.new(stylist_id: params[:stylist_id], starts_on: date, ends_on: date)
  end

  def create
    @time_off = TimeOff.new(params.expect(time_off: [ :stylist_id, :starts_on, :ends_on, :note ]))
    if @time_off.save
      redirect_to team_schedule_path(week: @time_off.starts_on.beginning_of_week), notice: "Time off added. Availability is up to date.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    time_off = TimeOff.find(params[:id])
    week = time_off.starts_on.beginning_of_week
    time_off.destroy!
    redirect_to team_schedule_path(week: week), notice: "Time off removed. The underlying shift or recurring hours apply again.", status: :see_other
  end

  private

  def load_stylists
    @stylists = Stylist.order(:name)
  end
end
