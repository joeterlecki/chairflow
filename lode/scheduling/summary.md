# Scheduling

> Status: planned, not yet implemented. **Deliberately simple for the MVP.** Per-stylist availability (working hours, breaks, time off, processing time) will be redesigned from scratch after the MVP. The POC's approach is not being reused.

## MVP rules
1. **Salon hours**, set by the salon on the Salon hours page (default 8 AM to 6 PM every day), are the only bookable window, the same for every stylist. See [salon-hours.md](salon-hours.md).
2. A booked appointment never overlaps another booked appointment for the same stylist. See [overlap-prevention.md](overlap-prevention.md).
3. Intervals are half-open, `[starts_at, ends_at)`, so back-to-back appointments are allowed.
4. Open slots start on the 15-minute grid in local wall-clock time.

## Schema (planned)
```ruby
create_table :stylists do |t|
  t.string  :name,   null: false
  t.string  :swatch, null: false          # see ui/design-tokens.md
  t.boolean :active, null: false, default: true
  t.timestamps
end

create_table :services do |t|
  t.string  :name,                     null: false
  t.integer :default_duration_minutes, null: false
  t.boolean :active, null: false, default: true
  t.timestamps
end

create_table :appointments do |t|
  t.references :client,  null: false, foreign_key: true
  t.references :stylist, null: false, foreign_key: true
  t.datetime :starts_at, null: false       # UTC
  t.datetime :ends_at,   null: false       # UTC; starts_at + total duration
  t.string   :status,    null: false, default: "booked"   # booked | cancelled
  t.text     :notes
  t.timestamps
end
add_index :appointments, [:stylist_id, :starts_at]

create_table :appointment_services do |t|
  t.references :appointment, null: false, foreign_key: true
  t.references :service,     null: false, foreign_key: true
  t.integer :position,         null: false
  t.integer :duration_minutes, null: false
end
```

`ends_at` is stored so overlap queries stay simple and indexable. It is always derived from the appointment's services, never typed by hand.

```mermaid
flowchart TD
  SH["SalonDay.hours_on(date)"] --> S[Candidate starts on 15-min grid]
  AP[Stylist's booked appointments] --> F
  D[Total duration of chosen services] --> F
  S --> F{Fits before closing<br/>and no overlap?}
  F -- yes --> O[Open slot]
```

## Files
- [salon-hours.md](salon-hours.md) - `SalonDay` model, the Salon hours page, wall-clock handling
- [availability.md](availability.md) - computing open slots
- [overlap-prevention.md](overlap-prevention.md) - no double-booking, including races
- [time-zones.md](time-zones.md) - UTC storage and DST
