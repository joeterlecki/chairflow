require "test_helper"

class DemoSeedsTest < ActiveSupport::TestCase
  test "demo seeds populate realistic shifts and rerun without changing existing data" do
    travel_to Time.zone.local(2030, 1, 9, 10) do
      stylist = Stylist.create!(name: "Melissa")
      stylist.working_days.find_by!(weekday: 1).update!(opens_at: "10:00")
      client = Client.create!(name: "Olivia Bennett", email: "personal@example.org", phone: "+44 20 7946 0000")
      original = Appointment.create!(stylist: stylist, client: client, service: "Cut & finish",
        starts_at: Time.zone.local(2030, 1, 7, 10), duration_minutes: 60, notes: "Keep this booking")

      load Rails.root.join("db/seeds.rb")
      assert_equal 48, Client.count
      assert_operator Appointment.count, :>, 150
      assert_operator Appointment.distinct.pluck(:service).size, :>=, 4
      assert_equal "10:00", stylist.working_days.find_by!(weekday: 1).opens_at
      assert_equal "personal@example.org", client.reload.email
      assert_equal "Keep this booking", original.reload.notes

      demo_stylist = Stylist.find_by!(name: "Zoe")
      assert demo_stylist.working_days.find_by!(weekday: 0).closed?
      assert_equal "12:00", demo_stylist.working_days.find_by!(weekday: 1).break_starts_at
      Appointment.find_each do |booking|
        assert booking.valid?, booking.errors.full_messages.join(", ")
        assert_not Appointment.where(client: booking.client).where.not(id: booking.id).overlapping(booking.starts_at, booking.ends_at).exists?
      end

      assert_no_difference [ "Appointment.count", "Client.count", "WorkingDay.count", "Service.count" ] do
        load Rails.root.join("db/seeds.rb")
      end
    end
  end
end
