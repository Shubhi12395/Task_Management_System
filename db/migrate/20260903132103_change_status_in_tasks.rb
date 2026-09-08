class ChangeStatusInTasks < ActiveRecord::Migration[8.1]
  def change
    change_column_default :tasks, :status, nil
    change_column :tasks, :status, :integer, using: 'status::integer'
  end
end
