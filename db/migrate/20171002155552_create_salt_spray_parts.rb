class CreateSaltSprayParts < ActiveRecord::Migration[5.1]
  def change
    create_table :salt_spray_parts do |t|
      t.bigint :salt_spray_test_id









      t.integer :barrel_number



      t.timestamps                      null: false
    end

  end
end
