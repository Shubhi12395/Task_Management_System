class FixCompletedInTasks < ActiveRecord::Migration[8.1]
  def change
       rename_column :tasks, :completed, :status
  end
end