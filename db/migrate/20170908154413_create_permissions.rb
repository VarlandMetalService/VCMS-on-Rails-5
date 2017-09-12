class CreatePermissions < ActiveRecord::Migration[5.1]

  def change
    
    create_table :permissions do |t|
      t.string :permission
      t.string :description
      t.integer :label_set, default: nil
    end
    
    add_index :permissions, :permission, unique: true
    
  end

end
