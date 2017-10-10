class CreateReasonCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :reason_codes do |t|
      t.string    :code
      t.boolean   :requires_notes
      t.boolean   :is_deleted

      t.timestamps
    end
  end
end
