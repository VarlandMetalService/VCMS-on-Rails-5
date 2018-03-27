class AddNotifySalesToSaltSprayTests < ActiveRecord::Migration[5.1]
  def change
    add_column :salt_spray_tests, :notify_sales, :boolean, default: false
  end
end
