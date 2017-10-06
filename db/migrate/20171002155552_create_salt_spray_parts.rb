class CreateSaltSprayParts < ActiveRecord::Migration[5.1]
  def change
    create_table :salt_spray_parts do |t|
      t.bigint :salt_spray_test_id
      t.bigint :shop_order_number
      t.integer :load_number
      t.string :customer
      t.string :process
      t.string :part_number
      t.string :sub
      t.integer :white_spec
      t.integer :red_spec
      t.integer :dept
      t.integer :barrel_number
      t.decimal :load_weight,   precision: 10, scale: 4
      t.decimal :part_area,             precision: 10, scale: 4
      t.decimal :ft_cubed_per_pound,    precision: 10, scale: 4
      t.timestamps                      null: false
    end

    add_index :salt_spray_parts, [:shop_order_number, :load_number, :sub], unique: true, name: 'shop_order_unique_index'
  end
end
