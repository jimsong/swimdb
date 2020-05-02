class CreateRelays < ActiveRecord::Migration[6.0]
  def change
    create_table :relays do |t|
      t.references :meet, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.references :age_group, null: false, foreign_key: true
      t.string :name
      t.references :swimmer1, foreign_key: { to_table: :swimmers }
      t.references :swimmer2, foreign_key: { to_table: :swimmers }
      t.references :swimmer3, foreign_key: { to_table: :swimmers }
      t.references :swimmer4, foreign_key: { to_table: :swimmers }
      t.integer :time_ms, null: false, index: true

      t.timestamps
    end
  end
end
