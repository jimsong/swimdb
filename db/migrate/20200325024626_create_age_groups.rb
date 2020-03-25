class CreateAgeGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :age_groups do |t|
      t.string :gender, limit: 1, null: false
      t.integer :start_age, limit: 2, null: false
      t.integer :end_age, limit: 2
      t.boolean :relay, null: false, default: false

      t.index [:gender, :start_age, :relay], unique: true
    end
  end
end
