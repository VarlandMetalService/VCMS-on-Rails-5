class AddSampleCodeToSaltSprayTests < ActiveRecord::Migration[5.1]
  def change
    add_column :salt_spray_tests, :sample_code, :string
  end
end
