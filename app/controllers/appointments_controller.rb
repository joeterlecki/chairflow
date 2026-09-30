class AppointmentsController < ApplicationController
  def show
    @appointment = Appointment.find(params[:id])
  end

  def new
    @appointment = Appointment.new
    @appointment.appointment_services.build
  end

  def create
    @appointment = Appointment.new(appointment_attributes)
    if @appointment.save
      redirect_to root_path(date: @appointment.starts_at.to_date),
        notice: "Booked. #{@appointment.client.name} is in with #{@appointment.stylist.name} at #{@appointment.starts_at.strftime('%-l:%M')}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Picked from Service.active, not typed -- creating services (and, later,
  # setting prices) is an admin/power-user job, not something the front desk
  # does implicitly while booking. See lode/booking/summary.md.
  def appointment_attributes
    attrs = params.expect(appointment: [ :client_id, :stylist_id, :starts_at ]).to_h
    attrs["appointment_services_attributes"] = service_rows
    attrs
  end

  def service_rows
    raw_rows = params.dig(:appointment, :appointment_services_attributes)&.values || []
    raw_rows.each_with_index.filter_map do |row, index|
      next if row[:service_id].blank?

      { service_id: row[:service_id], duration_minutes: row[:duration_minutes].presence, position: index + 1 }
    end
  end
end
