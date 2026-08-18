class ChangePriorityInTasks < ActiveRecord::Migration[8.1]
  def up
    change_column :tasks, :priority, :string
  end

  def down
    change_column :tasks, :priority, :integer
  end
end
