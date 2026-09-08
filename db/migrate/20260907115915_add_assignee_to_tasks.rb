class AddAssigneeToTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :assignee_id, :bigint, null: true
    add_foreign_key :tasks, :users, column: :assignee_id
  end
end
