class CreateSalonDays < ActiveRecord::Migration[8.1]
  def change
    create_table :salon_days do |t|
      t.integer :wday, null: false
      t.boolean :closed, null: false, default: false
      t.integer :opens_minute, null: false, default: 480
      t.integer :closes_minute, null: false, default: 1080

      t.timestamps
    end
    add_index :salon_days, :wday, unique: true
  end
end
