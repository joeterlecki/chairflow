class RenameDemoStylists < ActiveRecord::Migration[8.1]
  def up
    rename_stylists("Alex Morgan" => "Melissa", "Jamie Chen" => "Zoe", "Sam Rivera" => "Lauren")
  end

  def down
    rename_stylists("Melissa" => "Alex Morgan", "Zoe" => "Jamie Chen", "Lauren" => "Sam Rivera")
  end

  private

  def rename_stylists(names)
    names.each do |old_name, new_name|
      execute "UPDATE stylists SET name = #{connection.quote(new_name)} WHERE name = #{connection.quote(old_name)}"
    end
  end
end
