class CreateAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :attachments do |t|
      t.bigint :attachable_id
      t.string :attachable_type
      t.string :content_type
      t.timestamps
      t.string :file
    end
  end
end
