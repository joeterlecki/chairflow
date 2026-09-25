class AddTeamSchedule < ActiveRecord::Migration[8.1]
  def change
    create_table :scheduled_shifts do |t|
      t.references :stylist, null: false, foreign_key: true
      t.date :date, null: false
      t.boolean :closed, null: false, default: false
      t.string :opens_at, null: false, default: "09:00"
      t.string :closes_at, null: false, default: "18:00"
      t.string :break_starts_at
      t.string :break_ends_at
      t.timestamps
    end
    add_index :scheduled_shifts, [ :stylist_id, :date ], unique: true

    create_table :time_offs do |t|
      t.references :stylist, null: false, foreign_key: true
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.string :note
      t.timestamps
    end
    add_index :time_offs, [ :stylist_id, :starts_on, :ends_on ]
    add_check_constraint :time_offs, "ends_on >= starts_on", name: "time_off_dates_in_order"
  end
end
