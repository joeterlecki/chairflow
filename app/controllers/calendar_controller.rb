class CalendarController < ApplicationController
  def index
    @date = Date.current
    @stylists = Stylist.active
    @window = SalonDay.hours_on(@date)
    @appointments = Appointment.booked.on(@date).includes(:client, :services)
  end
end
