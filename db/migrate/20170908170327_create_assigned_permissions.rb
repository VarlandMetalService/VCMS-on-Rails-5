class CreateAssignedPermissions < ActiveRecord::Migration[5.1]

  def change

    create_table :assigned_permissions do |t|
      t.bigint :user_id
      t.bigint :permission_id
      t.integer :value
      t.timestamps null: false
    end

    add_foreign_key :assigned_permissions,  :users
    add_foreign_key :assigned_permissions,  :permissions

  end

end
