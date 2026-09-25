class User < ApplicationRecord
  has_secure_password
  normalizes :username, with: ->(username) { username.strip.downcase }
  validates :username, presence: true, uniqueness: true
end
