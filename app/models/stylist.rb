class Stylist < ApplicationRecord
  SWATCHES = %w[lavender sage clay sky sand].freeze

  has_many :appointments

  validates :name, presence: true
  validates :swatch, presence: true, inclusion: { in: SWATCHES }

  scope :active, -> { where(active: true) }
end
