class Stylist < ApplicationRecord
  COLORS = %w[sage clay lavender blue].freeze
  has_many :appointments, dependent: :restrict_with_error
  has_many :preferred_clients, class_name: "Client", foreign_key: :preferred_stylist_id, dependent: :nullify, inverse_of: :preferred_stylist
  has_many :working_days, dependent: :destroy
  has_many :scheduled_shifts, dependent: :destroy
  has_many :time_offs, dependent: :destroy
  accepts_nested_attributes_for :working_days
  after_create :create_default_schedule
  validates :name, presence: true
  validates :color, inclusion: { in: COLORS }

  def schedule_override_for(date)
    time_offs.find { |absence| absence.covers?(date) } || scheduled_shifts.find { |shift| shift.date == date }
  end

  def schedule_for(date)
    schedule_override_for(date) || working_days.find { |day| day.weekday == date.wday }
  end

  private

  def create_default_schedule
    7.times { |weekday| working_days.create!(weekday: weekday) }
  end
end
