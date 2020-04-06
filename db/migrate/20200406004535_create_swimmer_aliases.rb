class CreateSwimmerAliases < ActiveRecord::Migration[6.0]
  def change
    create_table :swimmer_aliases do |t|
      t.string :first_name
      t.string :last_name
      t.references :swimmer

      t.timestamps

      t.index [:last_name, :first_name], unique: true
    end
  end
end
