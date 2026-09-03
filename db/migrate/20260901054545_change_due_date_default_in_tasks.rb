class ChangeDueDateDefaultInTasks < ActiveRecord::Migration[8.1]
  def change
    change_column_default :tasks, :due_date, from: nil, to: -> { "CURRENT_DATE + INTERVAL '7 days'" }
  end
end
