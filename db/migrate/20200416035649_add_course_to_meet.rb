class AddCourseToMeet < ActiveRecord::Migration[6.0]
  def change
    add_column :meets, :course, :string, after: :name
  end
end
