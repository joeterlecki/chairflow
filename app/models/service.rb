class Service < ApplicationRecord
  DEFAULTS = { "Cut & finish" => 60, "Color & cut" => 120, "Blowout" => 30, "Highlights" => 180, "Consultation" => 15 }.freeze
  validates :name, presence: true, uniqueness: true
  validates :default_duration, inclusion: { in: Appointment::DURATIONS }

  def self.default
    find_by(name: "Cut & finish") || order(:id).first
  end
end
