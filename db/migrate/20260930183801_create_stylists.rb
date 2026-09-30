class CreateStylists < ActiveRecord::Migration[8.1]
  def change
    create_table :stylists do |t|
      t.string :name, null: false
      t.string :swatch, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
