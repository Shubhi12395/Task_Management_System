class AddParentToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :parent, null: true, foreign_key: { to_table: :tasks }
  end
end
