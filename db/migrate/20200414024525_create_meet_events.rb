class CreateMeetEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :meet_events do |t|
      t.references :meet, null: false, foreign_key: { on_delete: :cascade }
      t.references :event, null: false, foreign_key: { on_delete: :cascade }
      t.integer :event_number, limit: 2
      t.date :event_date

      t.timestamps
    end
  end
end
