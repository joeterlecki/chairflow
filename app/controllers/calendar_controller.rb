class CalendarController < ApplicationController
  def index
    @date = parse_date(params[:date]) || Date.current
    @stylists = Stylist.active
    @window = SalonDay.hours_on(@date)
    @appointments = Appointment.booked.on(@date).includes(:client, :services)
  end

  private

  def parse_date(value)
    Date.iso8601(value) if value.present?
  rescue ArgumentError
    nil
  end
end
