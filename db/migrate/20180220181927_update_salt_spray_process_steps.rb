class UpdateSaltSprayProcessSteps < ActiveRecord::Migration[5.1]
  def change
    rename_column :salt_spray_process_steps, :name, :chromate
    change_column :salt_spray_process_steps, :thickness, :decimal, precision: 10, scale: 3
    add_column :salt_spray_process_steps, :top_coat, :string
  end
end
