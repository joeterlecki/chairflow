# Repeatable, additive demo data for the previous, current, and next week.
# Existing appointments, contact details, and customized schedules are preserved.
User.find_or_create_by!(username: "admin") do |user|
  user.password = ENV.fetch("ADMIN_PASSWORD")
end
Service::DEFAULTS.each do |name, duration|
  Service.find_or_create_by!(name: name) { |service| service.default_duration = duration }
end

stylists = [ [ "Melissa", "sage" ], [ "Zoe", "clay" ], [ "Lauren", "lavender" ] ].map do |name, color|
  Stylist.find_or_create_by!(name: name) { |stylist| stylist.color = color }
end

# Upgrade only an untouched 9–6 schedule. Do not close a shift or introduce
# a break over an existing booking, even if that booking is in another week.
stylists.each_with_index do |stylist, index|
  next unless stylist.working_days.all? { |day| !day.closed? && day.opens_at == "09:00" && day.closes_at == "18:00" && day.break_starts_at.blank? && day.break_ends_at.blank? }

  stylist.working_days.each do |day|
    day.assign_attributes(closed: day.weekday.zero?, closes_at: day.weekday == 6 ? "16:00" : (index == 1 ? "17:00" : "18:00"),
      break_starts_at: index == 2 ? "11:30" : "12:00", break_ends_at: index == 2 ? "12:30" : "13:00")
    existing = stylist.appointments.select { |booking| booking.starts_at.wday == day.weekday }
    if existing.all? { |booking| day.permits?(booking.starts_at, booking.ends_at) }
      day.save!
    else
      day.reload
    end
  end
end

names = [
  "Olivia Bennett", "Noah Williams", "Emma Davis", "Ava Thompson", "Isabella Martinez", "Mia Wilson",
  "Sofia Anderson", "Lucas Taylor", "Amelia Lee", "Charlotte Brown", "Harper Clark", "Evelyn Lewis",
  "Benjamin Walker", "Chloe Hall", "Ethan Young", "Grace Allen", "Henry King", "Lily Wright",
  "Jack Scott", "Zoe Green", "Leo Adams", "Nora Baker", "Owen Nelson", "Ruby Carter",
  "Elijah Mitchell", "Ella Perez", "James Roberts", "Maya Turner", "Liam Phillips", "Lucy Campbell",
  "Oliver Parker", "Hazel Evans", "Sebastian Edwards", "Aria Collins", "Theo Stewart", "Violet Morris",
  "Oscar Reed", "Ivy Cook", "Julian Morgan", "Clara Bell", "Felix Murphy", "Alice Bailey",
  "Caleb Cooper", "Stella Richardson", "Miles Cox", "Naomi Howard", "Jasper Ward", "Elena Torres"
]
new_clients = []
clients = names.each_with_index.map do |name, index|
  client = Client.find_or_initialize_by(name: name)
  new_clients << client if client.new_record?
  # Reserved example addresses and fictional North American phone numbers.
  client.email = "#{name.downcase.tr(' ', '.')}@example.com" if client.email.blank?
  client.phone = format("+1 212 555 %04d", 100 + index) if client.phone.blank?
  client.save! if client.new_record? || client.changed?
  client
end

# Weight the service mix toward cuts and blowouts with some longer color visits.
services = [ "Cut & finish", "Cut & finish", "Color & cut", "Blowout", "Blowout", "Highlights", "Consultation" ].map { |name| Service.find_by!(name: name) }
notes = [ "", "", "Demo: prefers a quiet appointment.", "Demo: discuss maintaining the current length.", "Demo: allow time for a style consultation." ]

((Date.current.beginning_of_week - 7)..(Date.current.beginning_of_week + 13)).each do |date|
  stylists.each_with_index do |stylist, index|
    day = stylist.schedule_for(date)
    next if day.closed?

    opening = day.at(date, day.opens_at)
    closing = day.at(date, day.closes_at)
    break_minutes = day.break_starts_at.present? ? (day.at(date, day.break_ends_at) - day.at(date, day.break_starts_at)) / 60 : 0
    # Different occupancy each day, leaving genuine spaces for trying the planner.
    target_minutes = ((closing - opening) / 60 - break_minutes) * (0.65 + ((date.wday + index) % 4) * 0.05)
    random = Random.new(date.jd * 10 + index)

    loop do
      booked_minutes = stylist.appointments.overlapping(date.in_time_zone, date.next_day.in_time_zone).sum { |booking| booking.duration_minutes }
      break if booked_minutes >= target_minutes - 15

      options = services.filter_map do |candidate|
        next if candidate.default_duration > target_minutes - booked_minutes + 15
        availability = DayAvailability.new(stylist: stylist, starts_at: opening, duration: candidate.default_duration)
        slot = availability.open_slots.sample(random: random)
        [ candidate, slot ] if slot
      end
      break if options.empty?
      service, start = options.sample(random: random)

      # A client should never appear in two chairs at once in the demo.
      busy_ids = Appointment.overlapping(start, start + service.default_duration.minutes).pluck(:client_id)
      client = clients.reject { |candidate| busy_ids.include?(candidate.id) }.sample(random: random)
      break unless client

      Appointment.create!(stylist: stylist, client: client, service: service.name, starts_at: start,
        duration_minutes: service.default_duration, notes: notes.sample(random: random))
    end
  end
end

new_clients.each do |client|
  client.update!(preferred_stylist_id: client.appointments.order(:starts_at, :id).first&.stylist_id)
end

puts "Demo ready: #{Stylist.count} stylists, #{Client.count} clients, #{Appointment.count} appointments."
