class AddSalonSettings < ActiveRecord::Migration[8.1]
  def up
    add_column :clients, :email, :string
    add_column :clients, :phone, :string
    create_table :services do |t|
      t.string :name, null: false
      t.integer :default_duration, null: false
      t.timestamps
    end
    add_index :services, :name, unique: true
    create_table :working_days do |t|
      t.references :stylist, null: false, foreign_key: true
      t.integer :weekday, null: false
      t.boolean :closed, null: false, default: false
      t.string :opens_at, null: false, default: "09:00"
      t.string :closes_at, null: false, default: "18:00"
      t.string :break_starts_at
      t.string :break_ends_at
      t.timestamps
    end
    add_index :working_days, [ :stylist_id, :weekday ], unique: true

    now = connection.quote(Time.current)
    { "Cut & finish" => 60, "Color & cut" => 120, "Blowout" => 30, "Highlights" => 180, "Consultation" => 15 }.each do |name, duration|
      execute "INSERT INTO services (name, default_duration, created_at, updated_at) VALUES (#{connection.quote(name)}, #{duration}, #{now}, #{now})"
    end
    # Start existing teams with the previously advertised hours; do not introduce
    # breaks retroactively over their existing appointments.
    execute "INSERT INTO working_days (stylist_id, weekday, closed, opens_at, closes_at, created_at, updated_at) SELECT stylists.id, days.day, 0, '09:00', '18:00', #{now}, #{now} FROM stylists CROSS JOIN (SELECT 0 AS day UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) days"
  end

  def down
    drop_table :working_days
    drop_table :services
    remove_column :clients, :email
    remove_column :clients, :phone
  end
end
