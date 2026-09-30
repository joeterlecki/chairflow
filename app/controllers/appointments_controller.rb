class AppointmentsController < ApplicationController
  def show
    @appointment = Appointment.find(params[:id])
  end

  def new
    @date = parse_date(params[:date]) || Date.current
    @appointment = Appointment.new
    @appointment.appointment_services.build
  end

  # New clients are created in the same transaction as the appointment, so a
  # booking that fails for any other reason (e.g. a time clash) leaves no
  # orphan client behind.
  def create
    @appointment = Appointment.new(appointment_attributes)
    @new_client_name = new_client_name

    Appointment.transaction do
      if @appointment.client.nil? && @new_client_name.present?
        @appointment.client = Client.create!(name: @new_client_name, preferred_stylist: @appointment.stylist)
      end
      @appointment.save!
    end

    redirect_to root_path(date: @appointment.starts_at.to_date),
      notice: "Booked. #{@appointment.client.name} is in with #{@appointment.stylist.name} at #{@appointment.starts_at.strftime('%-l:%M')}."
  rescue ActiveRecord::RecordInvalid
    @date = @appointment.starts_at&.to_date || Date.current
    render :new, status: :unprocessable_entity
  end

  # "Find the right moment": open slots for a stylist/date/total-duration, reloaded
  # via Turbo Frame whenever the stylist or services change. Before a stylist is
  # chosen (or no services yet), there's nothing to compute -- a placeholder
  # message renders instead, never an empty-looking box.
  def day_planner
    date = parse_date(params[:date]) || Date.current
    stylist = Stylist.active.find_by(id: params[:stylist_id])
    minutes = params[:minutes].to_i

    @slots = stylist && minutes.positive? ? Availability.new(stylist: stylist, date: date, duration: minutes.minutes).open_slots : []
    @stylist = stylist
    @minutes = minutes

    render layout: false
  end

  # The client search box: matches as you type, with "+ Add ... as a new
  # client" always the last option. No matches for a blank query -- the
  # front desk hasn't typed anything to search for yet.
  def client_search
    @query = params[:q].to_s.strip
    @clients = @query.present? ? Client.matching(@query).alphabetical.limit(5) : Client.none

    render layout: false
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

  def new_client_name
    params.dig(:appointment, :new_client_name).to_s.strip
  end

  def service_rows
    raw_rows = params.dig(:appointment, :appointment_services_attributes)&.values || []
    raw_rows.each_with_index.filter_map do |row, index|
      next if row[:service_id].blank?

      { service_id: row[:service_id], duration_minutes: row[:duration_minutes].presence, position: index + 1 }
    end
  end

  def parse_date(value)
    Date.iso8601(value) if value.present?
  rescue ArgumentError
    nil
  end
end
