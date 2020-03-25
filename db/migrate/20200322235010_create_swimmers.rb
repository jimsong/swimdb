class CreateSwimmers < ActiveRecord::Migration[6.0]
  def change
    create_table :swimmers do |t|
      t.string :usms_permanent_id, null: false
      t.string :first_name
      t.string :last_name
      t.string :gender, limit: 1, null: false
      t.date :birth_date, null: false

      t.timestamps

      t.index :usms_permanent_id, unique: true
    end
  end
end
