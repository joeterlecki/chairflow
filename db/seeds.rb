# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

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
