class AddDatesToMeet < ActiveRecord::Migration[6.0]
  def change
    add_column :meets, :start_date, :date, after: :year
    add_column :meets, :end_date, :date, after: :start_date
  end
end
