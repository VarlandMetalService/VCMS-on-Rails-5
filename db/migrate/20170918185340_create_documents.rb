class CreateDocuments < ActiveRecord::Migration[5.1]

  def change

    create_table :documents do |t|
      t.integer     :added_by
      t.string      :name
      t.boolean     :is_valid
      t.string      :content_type
      t.string      :file
      t.string      :google_url,            default: nil
      t.string      :google_id,             default: nil
      t.text        :google_contents,       default: nil
      t.datetime    :google_updated_at,     default: nil
      t.timestamps                          null: false
      t.date        :document_updated_on
      t.boolean     :exclude_from_newest,   default: false
    end

  end

end
