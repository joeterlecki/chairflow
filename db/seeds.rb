# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Appointments are anchored to Date.current (not fixed calendar dates), so the day view always has something to
# show "today" and "tomorrow" regardless of when this runs. Test fixtures (test/fixtures/*.yml), not this file,
# back the test suite -- this data is for browsing the app in development.

[
  { name: "Melissa", swatch: "sage" },
  { name: "Devon", swatch: "clay" },
  { name: "Ari", swatch: "lavender" }
].each do |attrs|
  Stylist.find_or_create_by!(name: attrs[:name]) { |s| s.swatch = attrs[:swatch] }
end

[
  { name: "Cut & finish", default_duration_minutes: 45 },
  { name: "Blowout", default_duration_minutes: 30 },
  { name: "Gloss", default_duration_minutes: 30 },
  { name: "Highlights", default_duration_minutes: 120 },
  { name: "Color", default_duration_minutes: 90 }
].each do |attrs|
  Service.find_or_create_by!(name: attrs[:name]) { |s| s.default_duration_minutes = attrs[:default_duration_minutes] }
end

# Monday closed, matching the test fixtures, so the closed-day message is visible in development too.
[
  { wday: 0, closed: false },
  { wday: 1, closed: true },
  { wday: 2, closed: false },
  { wday: 3, closed: false },
  { wday: 4, closed: false },
  { wday: 5, closed: false },
  { wday: 6, closed: false }
].each do |attrs|
  day = SalonDay.find_or_initialize_by(wday: attrs[:wday])
  day.opens_minute ||= 480
  day.closes_minute ||= 1080
  day.closed = attrs[:closed]
  day.save!
end

melissa = Stylist.find_by!(name: "Melissa")
devon = Stylist.find_by!(name: "Devon")
ari = Stylist.find_by!(name: "Ari")

cut = Service.find_by!(name: "Cut & finish")
blowout = Service.find_by!(name: "Blowout")
gloss = Service.find_by!(name: "Gloss")
highlights = Service.find_by!(name: "Highlights")

[
  { name: "Ava Thompson", email: "ava@example.com", phone: "5551234567", preferred_stylist: melissa },
  { name: "Noah Carter", email: "noah@example.com", phone: "5552223333", preferred_stylist: devon },
  { name: "Priya Patel", email: "priya@example.com", phone: "5553334444", preferred_stylist: ari },
  { name: "Jordan Lee", email: nil, phone: "5554445555", preferred_stylist: nil }
].each do |attrs|
  Client.find_or_create_by!(name: attrs[:name]) do |c|
    c.email = attrs[:email]
    c.phone = attrs[:phone]
    c.preferred_stylist = attrs[:preferred_stylist]
  end
end

ava = Client.find_by!(name: "Ava Thompson")
noah = Client.find_by!(name: "Noah Carter")
priya = Client.find_by!(name: "Priya Patel")

# One appointment per stylist, each day, for today and tomorrow -- skipping closed days. Melissa's is a single
# short service, Devon's combines two services, Ari's is long, so the day view shows cards of different heights.
[ Date.current, Date.current + 1.day ].each do |date|
  next if SalonDay.hours_on(date).nil?

  Appointment.find_or_create_by!(client: ava, stylist: melissa, starts_at: date.in_time_zone.change(hour: 9)) do |a|
    a.appointment_services_attributes = [ { service: cut, position: 1, duration_minutes: cut.default_duration_minutes } ]
  end

  Appointment.find_or_create_by!(client: noah, stylist: devon, starts_at: date.in_time_zone.change(hour: 10, min: 30)) do |a|
    a.appointment_services_attributes = [
      { service: blowout, position: 1, duration_minutes: blowout.default_duration_minutes },
      { service: gloss, position: 2, duration_minutes: gloss.default_duration_minutes }
    ]
  end

  Appointment.find_or_create_by!(client: priya, stylist: ari, starts_at: date.in_time_zone.change(hour: 13)) do |a|
    a.appointment_services_attributes = [
      { service: highlights, position: 1, duration_minutes: highlights.default_duration_minutes }
    ]
  end
end
