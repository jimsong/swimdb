class CreateRelays < ActiveRecord::Migration[6.0]
  def change
    create_table :relays do |t|
      t.references :meet, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.references :age_group, null: false, foreign_key: true
      t.references :swimmer1, null: false, foreign_key: { to_table: :swimmers }
      t.references :swimmer2, null: false, foreign_key: { to_table: :swimmers }
      t.references :swimmer3, null: false, foreign_key: { to_table: :swimmers }
      t.references :swimmer4, null: false, foreign_key: { to_table: :swimmers }
      t.integer :time_ms, null: false, index: true

      t.timestamps
    end
  end
end
