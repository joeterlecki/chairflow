class Client < ApplicationRecord
  has_many :appointments, dependent: :restrict_with_error
  belongs_to :preferred_stylist, class_name: "Stylist", optional: true
  validates :preferred_stylist, presence: true, if: -> { preferred_stylist_id.present? }
  validates :name, presence: true, length: { maximum: 100 }
  normalizes :name, with: ->(name) { name.strip }
  normalizes :email, with: ->(email) { email.strip.downcase.presence }
  normalizes :phone, with: ->(phone) { phone.strip.presence }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 254 }, allow_blank: true
  validates :phone, format: { with: /\A\+?[\d\s().-]+\z/ }, length: { in: 7..30 }, allow_blank: true

  def label
    [ name, email.presence || phone.presence ].compact.join(" · ")
  end
end
