class CreateResults < ActiveRecord::Migration[6.0]
  def change
    create_table :results do |t|
      t.references :meet, null: false
      t.references :event, null: false
      t.references :age_group, null: false
      t.references :swimmer, null: false
      t.integer :time_ms, null: false, index: true

      t.timestamps
    end
  end
end
