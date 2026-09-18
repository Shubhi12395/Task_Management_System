class AddColumnToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :time_stamp, :datetime, default: Time.current
  end
end
