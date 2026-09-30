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
  rescue ActiveRecord::RecordInvalid => e
    @appointment = Appointment.new(basic_attributes)
    @appointment.appointment_services.build
    @appointment.errors.add(:base, "Couldn't save that service: #{e.record.errors.full_messages.to_sentence}")
    render :new, status: :unprocessable_entity
  end

  private

  # Each service row is a typed name, not a picked service_id: a name matching an
  # existing (case-insensitive) service reuses it, any other name creates a new
  # one. There's one catalog, not a separate "custom" track -- see
  # lode/booking/summary.md.
  def appointment_attributes
    basic_attributes.merge(appointment_services_attributes: service_rows)
  end

  def basic_attributes
    params.expect(appointment: [ :client_id, :stylist_id, :starts_at ]).to_h
  end

  def service_rows
    raw_rows = params.dig(:appointment, :appointment_services_attributes)&.values || []
    raw_rows.each_with_index.filter_map do |row, index|
      name = row[:service_name].to_s.strip
      next if name.blank?

      service = Service.where("LOWER(name) = ?", name.downcase).first_or_create! do |s|
        s.name = name
        s.default_duration_minutes = row[:duration_minutes].presence || 30
      end

      { service_id: service.id, service_name: service.name, duration_minutes: row[:duration_minutes].presence, position: index + 1 }
    end
  end
end
