# Clients

> Status: the model below is implemented. Booking (see [../booking/summary.md](../booking/summary.md)) can now find an existing client or create a new one inline, but doesn't call `possible_duplicates_of` yet — the duplicate warning below is still planned. Pages (index/profile/edit) are still planned.

A client is a person who gets appointments. Keep the record light: a name, optional ways to reach them, and a preferred stylist. No CRM features.

```ruby
# app/models/client.rb
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
    candidate = new(name: name, email: email, phone: phone)   # reuse the normalizers
    scope = where("LOWER(name) = ?", candidate.name.to_s.strip.downcase)
    scope = scope.or(where(email: candidate.email)) if candidate.email.present?
    scope = scope.or(where(phone: candidate.phone)) if candidate.phone.present?
    scope
  end
end
```

## Duplicate warning
When a new client is added (in booking or on the Clients page) and `possible_duplicates_of` finds matches, show a gentle interruption instead of saving:

> *Looks like Ava Thompson might already be here (same phone).* **Use Ava** · **Add as someone new**

Choosing "Add as someone new" saves anyway. Clients are **never merged**. Duplicates are an accepted cost of never blocking the desk.

```mermaid
flowchart LR
  N[New client details] --> Q{Possible duplicates?}
  Q -- none --> S[Save]
  Q -- found --> W[Warn with matches]
  W -->|Use existing| E[Pick existing client]
  W -->|Add as someone new| S
```

## Invariants
- A client with appointments is never hard-deleted (`restrict_with_error`).
- The preferred stylist is a suggestion for booking, never a constraint.
- Contact details in the appointment detail are links (`mailto:`, `tel:`).

## Pages (MVP)
- **Index**: eyebrow "The people who come back", headline "Your clients.", with search.
- **Profile**: eyebrow "A familiar face", headline = name. Upcoming and past visits, preferred stylist, contact, **Book again**.
- **Edit**: contact details and preferred stylist.
