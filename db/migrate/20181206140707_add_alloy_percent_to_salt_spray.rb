class AddAlloyPercentToSaltSpray < ActiveRecord::Migration[5.1]
  def change
    add_column :salt_spray_tests, :alloy_percent, :float
  end
end
