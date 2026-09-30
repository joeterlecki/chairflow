class Client < ApplicationRecord
  belongs_to :preferred_stylist, class_name: "Stylist", optional: true
  has_many :appointments, dependent: :restrict_with_error

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :phone, with: ->(phone) { phone.gsub(/[^\d+]/, "") }

  validates :name, presence: true

  scope :alphabetical, -> { order(:name) }
  scope :matching, ->(q) { where("name LIKE ?", "%#{sanitize_sql_like(q)}%") }

  # Soft check used before creating a client. Never blocks, never merges.
  def self.possible_duplicates_of(name:, email: nil, phone: nil)
    candidate = new(name: name, email: email, phone: phone)
    scope = where("LOWER(name) = ?", candidate.name.to_s.strip.downcase)
    scope = scope.or(where(email: candidate.email)) if candidate.email.present?
    scope = scope.or(where(phone: candidate.phone)) if candidate.phone.present?
    scope
  end
end
