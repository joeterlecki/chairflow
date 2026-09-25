class Appointment < ApplicationRecord
  SERVICES = [ "Cut & finish", "Color & cut", "Blowout", "Highlights", "Consultation" ].freeze
  DURATIONS = [ 15, 30, 45, 60, 90, 120, 180 ].freeze

  belongs_to :stylist
  belongs_to :client
  validates_associated :client
  validates :service, inclusion: { in: ->(_) { Service.pluck(:name) } }
  validates :starts_at, :ends_at, presence: true
  validates :duration_minutes, inclusion: { in: DURATIONS }
  validates :notes, length: { maximum: 2000 }
  validate :same_day
  validate :stylist_available
  validate :within_working_hours

  scope :overlapping, ->(from, to) { where("starts_at < ? AND ends_at > ?", to, from) }

  def duration_minutes
    @duration_minutes || (starts_at && ends_at && ((ends_at - starts_at) / 60).round) || 60
  end

  def duration_minutes=(value)
    @duration_minutes = value.to_i
  end

  before_validation :calculate_end

  private

  def within_working_hours
    return unless stylist && starts_at && ends_at
    return if persisted? && !will_save_change_to_starts_at? && !will_save_change_to_ends_at? && !will_save_change_to_stylist_id?

    # Saving must recheck current coverage, even if this appointment's stylist
    # association was loaded before a shift or time-off change.
    day = Stylist.find_by(id: stylist_id)&.schedule_for(starts_at.to_date)
    unless day&.permits?(starts_at, ends_at)
      errors.add(:base, "Choose a time within this stylist’s working hours and outside their break")
    end
  end

  def calculate_end
    self.ends_at = starts_at + duration_minutes.minutes if starts_at
  end

  def same_day
    if starts_at && ends_at && starts_at.to_date != ends_at.to_date
      errors.add(:base, "Appointments must start and finish on the same day")
    end
  end

  def stylist_available
    return unless starts_at && ends_at && stylist_id

    if self.class.where(stylist_id: stylist_id).where.not(id: id).overlapping(starts_at, ends_at).exists?
      errors.add(:base, "This stylist already has an appointment during that time. Choose another time or stylist.")
    end
  end
end
