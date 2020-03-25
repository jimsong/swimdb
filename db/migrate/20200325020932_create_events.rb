class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.integer :distance, limit: 2, null: false
      t.string :course, null: false
      t.string :stroke, null: false
      t.boolean :relay, null: false, default: false

      t.index [:distance, :course, :stroke, :relay], unique: true
    end
  end
end
