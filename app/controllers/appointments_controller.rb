class AppointmentsController < ApplicationController
  before_action :load_options, except: %i[availability show]
  before_action :set_appointment, only: %i[show edit update destroy]

  def show
  end

  def new
    day = (Date.iso8601(params[:date].to_s) rescue Date.current)
    service = Service.default
    time = params[:time].to_s.match?(WorkingDay::TIME_FORMAT) ? params[:time] : "09:00"
    hour, minute = time.split(":").map(&:to_i)
    duration = params[:duration_minutes].to_i
    duration = service.default_duration unless Appointment::DURATIONS.include?(duration)
    @appointment = Appointment.new(starts_at: day.in_time_zone.change(hour: hour, min: minute), stylist_id: params[:stylist_id], service: service.name, duration_minutes: duration)
  end

  def create
    @appointment = Appointment.new
    save_appointment(:new)
  end

  def edit
  end

  def availability
    starts_at = Time.zone.parse(params[:starts_at].to_s)
    duration = params[:duration_minutes].to_i
    unless starts_at && Appointment::DURATIONS.include?(duration)
      return render plain: "Choose a valid date, time, and duration.", status: :unprocessable_entity
    end

    @availability = DayAvailability.new(stylist: Stylist.find_by(id: params[:stylist_id]),
      starts_at: starts_at, duration: duration, excluding_id: params[:appointment_id])
    render partial: "availability", locals: { availability: @availability }
  rescue ArgumentError
    render plain: "Choose a valid date and time.", status: :unprocessable_entity
  end

  def update
    save_appointment(:edit)
  end

  def destroy
    destination = helpers.back_to_calendar_path(@appointment)
    @appointment.destroy!
    redirect_to destination, notice: "Appointment cancelled.", status: :see_other
  end

  private

  def load_options
    @stylists = Stylist.order(:name)
    @clients = Client.order(:name)
    @services = Service.order(:id)
  end

  def set_appointment
    @appointment = Appointment.includes(:stylist, client: :preferred_stylist).find(params[:id])
  end

  def save_appointment(view)
    attributes = params.expect(appointment: [ :client_id, :new_client_name, :new_client_email, :new_client_phone, :new_client_preferred_stylist_id, :stylist_id, :service, :starts_at, :duration_minutes, :notes ])
    new_client_name = attributes.delete(:new_client_name)
    new_client_email = attributes.delete(:new_client_email)
    new_client_phone = attributes.delete(:new_client_phone)
    preference = attributes.delete(:new_client_preferred_stylist_id) { "booking_stylist" }
    if attributes[:duration_minutes].blank?
      attributes[:duration_minutes] = Service.find_by(name: attributes[:service])&.default_duration
    end
    @appointment.assign_attributes(attributes)
    if new_client_name.present?
      preferred_stylist_id = preference == "booking_stylist" ? @appointment.stylist_id : preference
      @appointment.client = Client.new(name: new_client_name, email: new_client_email, phone: new_client_phone, preferred_stylist_id: preferred_stylist_id)
    end

    if @appointment.save
      redirect_to helpers.back_to_calendar_path(@appointment), notice: "Appointment saved.", status: :see_other
    else
      render view, status: :unprocessable_entity
    end
  end
end
