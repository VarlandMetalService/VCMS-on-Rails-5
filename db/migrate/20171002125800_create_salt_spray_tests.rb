class CreateSaltSprayTests < ActiveRecord::Migration[5.1]
  def change
    create_table :salt_spray_tests do |t|
      t.bigint :put_on_by
      t.datetime :put_on_at
      t.datetime :date_off
      t.text :comments
      t.datetime :date_w_white
      t.bigint :who_called_white
      t.datetime :date_w_red
      t.bigint :who_called_red
      t.boolean :is_deleted,    default: false
      t.bigint :deleted_by
      t.boolean :is_archived,   default: false
      t.timestamps              null: false
    end

    add_foreign_key :salt_spray_tests, :users, column: :put_on_by
    add_foreign_key :salt_spray_tests, :users, column: :who_called_white
    add_foreign_key :salt_spray_tests, :users, column: :who_called_red

  end
end
