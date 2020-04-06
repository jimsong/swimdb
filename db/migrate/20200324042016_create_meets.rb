class CreateMeets < ActiveRecord::Migration[6.0]
  def change
    create_table :meets do |t|
      t.string :usms_meet_id, null: false
      t.string :name
      t.integer :year, limit: 2

      t.timestamps

      t.index :usms_meet_id, unique: true
      t.index :year
    end
  end
end
