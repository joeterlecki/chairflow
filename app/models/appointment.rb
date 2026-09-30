class Appointment < ApplicationRecord
  belongs_to :client
  belongs_to :stylist
  has_many :appointment_services, -> { order(:position) }, dependent: :destroy, inverse_of: :appointment
  has_many :services, through: :appointment_services
  accepts_nested_attributes_for :appointment_services, allow_destroy: true

  enum :status, { booked: "booked", cancelled: "cancelled" }, default: :booked

  before_validation :derive_ends_at
  validates :starts_at, presence: true
  validate :has_a_service

  def duration
    appointment_services.reject(&:marked_for_destruction?).sum(&:duration_minutes).minutes
  end

  private

  def derive_ends_at
    self.ends_at = starts_at + duration if starts_at
  end

  def has_a_service
    errors.add(:base, "Choose at least one service.") if duration.zero?
  end
end
