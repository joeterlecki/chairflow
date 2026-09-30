class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :client, null: false, foreign_key: true
      t.references :stylist, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :status, null: false, default: "booked"
      t.text :notes

      t.timestamps
    end
    add_index :appointments, [ :stylist_id, :starts_at ]
  end
end
