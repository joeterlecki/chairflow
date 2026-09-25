require "test_helper"

class TeamScheduleTest < ActionDispatch::IntegrationTest
  setup do
    @stylist = Stylist.create!(name: "Melissa")
    @client = Client.create!(name: "Morgan")
    @date = Date.new(2030, 1, 7)
  end

  test "dated shift changes one date and drives calendar and booking availability" do
    patch stylist_shift_path(@stylist, date: @date), params: { scheduled_shift: {
      opens_at: "11:00", closes_at: "19:00", break_starts_at: "14:00", break_ends_at: "15:00"
    } }
    assert_redirected_to team_schedule_path(week: @date)
    assert_equal "11:00", @stylist.reload.schedule_for(@date).opens_at
    assert_equal "09:00", @stylist.schedule_for(@date + 7).opens_at
    get team_schedule_path(week: @date)
    assert_select "td[data-date='2030-01-07']", text: /One-day change.*11:00–19:00/m
    get root_path(view: "day", date: @date)
    assert_select ".hour-label", text: "6:00 PM"
    assert_select ".break-block[title='Break: 14:00–15:00']"
    get availability_appointments_path, params: { stylist_id: @stylist.id, starts_at: "2030-01-07T10:00", duration_minutes: 60 }
    assert_select "[role=status]", text: /Outside working hours/
    assert_not booking(10).valid?
    assert booking(11).valid?
    assert_not booking(14).valid?
  end

  test "shift and recurring hour conflicts return actionable errors without saving" do
    appointment = booking(10)
    appointment.save!
    assert_no_difference "ScheduledShift.count" do
      patch stylist_shift_path(@stylist, date: @date), params: { scheduled_shift: { opens_at: "11:00" } }
    end
    assert_response :unprocessable_entity
    assert_select "a[href='#{edit_appointment_path(appointment)}']", text: /Morgan/
    day = @stylist.working_days.find_by!(weekday: 1)
    patch stylist_path(@stylist), params: { stylist: { working_days_attributes: { "0" => { id: day.id, closed: true } } } }
    assert_response :unprocessable_entity
    assert_select "a[href='#{edit_appointment_path(appointment)}']", text: /Morgan/
    assert_not day.reload.closed?
  end

  test "time off blocks the whole inclusive date range and removal restores dated shift" do
    shift = @stylist.scheduled_shifts.create!(date: @date, opens_at: "11:00", closes_at: "17:00")
    post time_offs_path, params: { time_off: { stylist_id: @stylist.id, starts_on: @date, ends_on: @date + 2, note: "Vacation" } }
    assert_response :see_other
    absence = TimeOff.last
    assert_instance_of TimeOff, @stylist.reload.schedule_for(@date)
    assert_instance_of TimeOff, @stylist.schedule_for(@date + 2)
    assert_instance_of WorkingDay, @stylist.schedule_for(@date + 3)
    assert_not booking(11).valid?
    get root_path(view: "day", date: @date)
    assert_select ".day-off-label", text: "Time off"
    assert_select ".calendar-open-slot", count: 0
    delete time_off_path(absence)
    assert_response :see_other
    assert_equal shift, @stylist.reload.schedule_for(@date)
    assert booking(11).valid?
  end

  test "time off rejects overlapping ranges, invalid dates and existing bookings atomically" do
    appointment = booking(10)
    appointment.save!
    assert_no_difference "TimeOff.count" do
      post time_offs_path, params: { time_off: { stylist_id: @stylist.id, starts_on: @date - 1, ends_on: @date + 1 } }
    end
    assert_response :unprocessable_entity
    assert_select "a[href='#{edit_appointment_path(appointment)}']", text: /Morgan/
    assert @stylist.reload.schedule_for(@date + 1).is_a?(WorkingDay)
    @stylist.time_offs.create!(starts_on: @date + 2, ends_on: @date + 4)
    assert_not @stylist.time_offs.new(starts_on: @date + 4, ends_on: @date + 5).valid?
    assert_not @stylist.time_offs.new(starts_on: @date + 4, ends_on: @date + 3).valid?
  end

  test "reverting a shift refuses to strand a booking outside recurring hours" do
    shift = @stylist.scheduled_shifts.create!(date: @date, opens_at: "08:00", closes_at: "18:00")
    appointment = booking(8)
    appointment.save!
    assert_no_difference "ScheduledShift.count" do
      delete stylist_shift_path(@stylist, date: @date)
    end
    assert_response :unprocessable_entity
    assert_select "a[href='#{edit_appointment_path(appointment)}']", text: /Morgan/
    appointment.destroy!
    delete stylist_shift_path(@stylist, date: @date)
    assert_response :see_other
    assert_not ScheduledShift.exists?(shift.id)
    assert_equal "09:00", @stylist.reload.schedule_for(@date).opens_at
  end

  test "recurring changes ignore bookings covered by a dated shift" do
    @stylist.scheduled_shifts.create!(date: @date, opens_at: "09:00", closes_at: "18:00")
    booking(10).save!
    day = @stylist.working_days.find_by!(weekday: 1)
    assert day.update(closed: true)
    assert_not @stylist.reload.schedule_for(@date).closed?
    assert @stylist.schedule_for(@date + 7).closed?
  end

  private

  def booking(hour)
    Appointment.new(stylist: @stylist.reload, client: @client, service: "Cut & finish", starts_at: @date.in_time_zone.change(hour: hour), duration_minutes: 60)
  end
end
