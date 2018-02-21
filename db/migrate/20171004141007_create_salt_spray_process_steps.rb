class CreateSaltSprayProcessSteps < ActiveRecord::Migration[5.1]

  def change

    create_table :salt_spray_process_steps do |t|
      t.bigint      :salt_spray_test_id
      t.string      :name
      t.decimal     :thickness
      t.integer     :dipping_time
      t.string      :note,            limit: 100

      t.timestamps  null: false
    end

  end

end
