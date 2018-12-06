class AddAlloyPercentToSaltSprayTestProcessStep < ActiveRecord::Migration[5.1]
  def change
    remove_column :salt_spray_tests, :alloy_percent, :float
    add_column :salt_spray_process_steps, :alloy_percent, :float
  end
end
