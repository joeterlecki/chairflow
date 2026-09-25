class CreateScheduling < ActiveRecord::Migration[8.1]
  def change
    create_table :stylists do |t|
      t.string :name, null: false
      t.string :color, null: false, default: "sage"
      t.timestamps
    end

    create_table :clients do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :appointments do |t|
      t.references :stylist, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.string :service, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.text :notes
      t.timestamps
    end
    add_index :appointments, [ :stylist_id, :starts_at, :ends_at ]
    add_check_constraint :appointments, "ends_at > starts_at", name: "positive_appointment_duration"
  end
end
