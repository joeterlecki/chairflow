# This script only resets Playwright's dedicated database, never development data.
unless Rails.env.test? && ActiveRecord::Base.connection_db_config.database == "storage/playwright.sqlite3"
  abort "Browser setup requires the isolated Playwright test database"
end

admin = User.find_or_initialize_by(username: "admin")
admin.password = "studio-test-password"
admin.save!

Appointment.delete_all
ScheduledShift.delete_all
TimeOff.delete_all
WorkingDay.delete_all
Stylist.delete_all
Client.delete_all
Service.delete_all
Service::DEFAULTS.each { |name, duration| Service.create!(name: name, default_duration: duration) }
%w[Alex Jamie].each { |name| Stylist.create!(name: name) }
Stylist.find_by!(name: "Alex").working_days.find_by!(weekday: 1).update!(break_starts_at: "12:00", break_ends_at: "13:00")
client = Client.create!(name: "Existing Client", email: "existing@example.com")
Appointment.create!(stylist: Stylist.find_by!(name: "Alex"), client: client, service: "Cut & finish",
  starts_at: Time.zone.local(2030, 1, 7, 10), duration_minutes: 60)
Appointment.create!(stylist: Stylist.find_by!(name: "Jamie"), client: Client.create!(name: "Parallel Client"), service: "Color & cut",
  starts_at: Time.zone.local(2030, 1, 7, 10), duration_minutes: 120)
