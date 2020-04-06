class CreateMeetsSwimmersJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_table :meets_swimmers, id: false do |t|
      t.references :swimmer
      t.references :meet
    end
  end
end
