class AddPreferredNamesToSwimmers < ActiveRecord::Migration[6.0]
  def change
    add_column :swimmers, :preferred_first_name, :string, after: :last_name
    add_column :swimmers, :preferred_last_name, :string, after: :preferred_first_name
    remove_column :swimmers, :birth_date
  end
end
