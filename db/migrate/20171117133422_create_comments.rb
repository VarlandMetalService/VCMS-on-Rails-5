class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.text :content
      t.string :created_by
      # TODO: convert :created_by to a bigint
      t.references :commentable, polymorphic: true

      t.timestamps
    end
  end
end
