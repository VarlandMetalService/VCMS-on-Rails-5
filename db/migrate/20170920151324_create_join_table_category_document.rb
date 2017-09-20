class CreateJoinTableCategoryDocument < ActiveRecord::Migration[5.1]
  def change
    create_join_table :categories, :documents do |t|
      t.index [:category_id, :document_id]
    end
  end
end
