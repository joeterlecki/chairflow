class AddPreferredStylistToClients < ActiveRecord::Migration[8.1]
  def up
    add_reference :clients, :preferred_stylist, foreign_key: { to_table: :stylists, on_delete: :nullify }, null: true
    execute <<~SQL
      UPDATE clients
      SET preferred_stylist_id = (
        SELECT stylist_id FROM appointments
        WHERE appointments.client_id = clients.id
        ORDER BY starts_at ASC, id ASC LIMIT 1
      )
    SQL
  end

  def down
    remove_reference :clients, :preferred_stylist, foreign_key: { to_table: :stylists }
  end
end
