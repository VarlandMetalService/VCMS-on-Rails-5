class CreateAssignedPermissions < ActiveRecord::Migration[5.1]

  def change

    create_table :assigned_permissions do |t|
      t.integer :user_id
      t.integer :permission_id
      t.integer :value
      t.timestamps null: false
    end
    
    add_foreign_key :assigned_permissions,  :users
    add_foreign_key :assigned_permissions,  :permissions
    
  end

end
