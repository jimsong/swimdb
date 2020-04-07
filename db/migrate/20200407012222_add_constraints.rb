class AddConstraints < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :results, :meets
    add_foreign_key :results, :events
    add_foreign_key :results, :age_groups
    add_foreign_key :results, :swimmers

    add_foreign_key :swimmer_aliases, :swimmers, on_delete: :cascade

    add_foreign_key :meets_swimmers, :meets
    add_foreign_key :meets_swimmers, :swimmers, on_delete: :cascade

    add_index :meets_swimmers, [:meet_id, :swimmer_id], unique: true
  end
end
