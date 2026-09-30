class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.references :preferred_stylist, null: true, foreign_key: { to_table: :stylists }

      t.timestamps
    end
  end
end
