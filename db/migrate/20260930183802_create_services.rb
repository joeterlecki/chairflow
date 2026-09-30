class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.integer :default_duration_minutes, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
