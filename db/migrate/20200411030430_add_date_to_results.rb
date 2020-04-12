class AddDateToResults < ActiveRecord::Migration[6.0]
  def change
    add_column :results, :date, :date, after: :time_ms
  end
end
