class CreateSaltSprayProcessSteps < ActiveRecord::Migration[5.1]

  def change

    create_table :salt_spray_process_steps do |t|
      t.bigint      :salt_spray_test_id
      t.string      :name
      t.string      :vat_name
      t.decimal     :temperature
      t.decimal     :ph
      t.integer     :barrel_rpm
      t.timestamp   :time_in
      t.timestamp   :time_out
      t.decimal     :amp_hours
      t.decimal     :target_amp_hours
      t.decimal     :thickness
      t.decimal     :alloy_percentage
      t.timestamps  null: false
    end

  end

end
