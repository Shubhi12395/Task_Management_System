class AddCreatorToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :creator_id, :bigint
    add_foreign_key :tasks, :users, column: :creator_id
  end
end
