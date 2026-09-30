class AppointmentsController < ApplicationController
  def show
    @appointment = Appointment.find(params[:id])
  end

  def new
    @appointment = Appointment.new
    @appointment.appointment_services.build
  end

  def create
    @appointment = Appointment.new(appointment_params)
    if @appointment.save
      redirect_to root_path(date: @appointment.starts_at.to_date),
        notice: "Booked. #{@appointment.client.name} is in with #{@appointment.stylist.name} at #{@appointment.starts_at.strftime('%-l:%M')}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def appointment_params
    params.expect(appointment: [ :client_id, :stylist_id, :starts_at, { appointment_services_attributes: [ [ :service_id, :position ] ] } ])
  end
end
