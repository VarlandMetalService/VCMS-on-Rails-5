class CreateCategories < ActiveRecord::Migration[5.1]

  def change

    create_table :categories do |t|
      t.string      :name
      t.integer     :parent_id,             null: true,    index: true
      t.integer     :lft,                   null: false,   index: true
      t.integer     :rgt,                   null: false,   index: true
      t.integer     :depth,                 null: false,   default: 0
      t.integer     :children_count,        null: false,   default: 0
      t.timestamps                          null: false
      t.integer     :position
      t.string      :google_drive_folder
    end

  end

end
