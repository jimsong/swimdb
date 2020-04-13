class DropMeetsSwimmers < ActiveRecord::Migration[6.0]
  def change
    drop_table :meets_swimmers, id: false do |t|
      t.references :swimmer
      t.references :meet
      t.index [:meet_id, :swimmer_id], unique: true
      t.foreign_key :meets
      t.foreign_key :swimmers, on_delete: :cascade
    end
  end
end
