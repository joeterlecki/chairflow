class Service < ApplicationRecord
  validates :name, presence: true
  validates :default_duration_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :active, -> { where(active: true) }
end
