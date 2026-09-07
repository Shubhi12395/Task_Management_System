class RemoveTasksFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_reference :tasks, :user, null: false, foreign_key: true
  end
end
