class AddOtpToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :otp_code, :integer
    add_column :users, :otp_expires_at, :datetime
  end
end
