class AddDateToRelays < ActiveRecord::Migration[6.0]
  def change
    add_column :relays, :date, :date, after: :time_ms
  end
end
