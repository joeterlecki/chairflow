class AppointmentService < ApplicationRecord
  belongs_to :appointment, inverse_of: :appointment_services
  belongs_to :service

  before_validation :default_duration_minutes_from_service

  validates :position, presence: true
  validates :duration_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }

  private

  def default_duration_minutes_from_service
    self.duration_minutes ||= service&.default_duration_minutes
  end
end
