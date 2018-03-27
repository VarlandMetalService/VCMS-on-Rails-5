class AddNotifyManagementToSaltSprayTests < ActiveRecord::Migration[5.1]
  def change
    add_column :salt_spray_tests, :notify_management, :boolean, default: false
  end
end
