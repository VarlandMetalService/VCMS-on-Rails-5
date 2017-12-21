class CreateSaltSprayTests < ActiveRecord::Migration[5.1]
  def change
    create_table :salt_spray_tests do |t|
      t.bigint :shop_order_number
      t.integer :load_number
      t.string :customer
      t.string :process_code
      t.string :part_number
      t.string :sub
      t.decimal :part_area,             precision: 10, scale: 4
      t.decimal :density,               precision: 10, scale: 4
      t.integer :white_spec,            default: 0
      t.integer :red_spec,              default: 0
      t.integer :dept
      t.decimal :load_weight,           precision: 10, scale: 4
      t.bigint :put_on_by
      t.datetime :put_on_at
      t.datetime :pulled_off_at
      t.bigint :pulled_off_by
      t.datetime :marked_white_at
      t.bigint :marked_white_by
      t.datetime :marked_red_at
      t.bigint :marked_red_by
      t.bigint :flagged_by
      t.bigint :checked_by
      t.boolean :is_sample,    default: false
      t.datetime :deleted_at
      t.bigint :deleted_by
      t.timestamps              null: false
    end

    add_foreign_key :salt_spray_tests, :users, column: :put_on_by
    add_foreign_key :salt_spray_tests, :users, column: :marked_white_by
    add_foreign_key :salt_spray_tests, :users, column: :marked_red_by
    add_foreign_key :salt_spray_tests, :users, column: :pulled_off_by

    add_index :salt_spray_tests, [:checked_by, :process_code], order: {checked_by: :asc, process_code: :desc}

  end
end
