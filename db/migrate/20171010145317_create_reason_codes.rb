class CreateReasonCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :reason_codes do |t|
      t.string    :code
      t.boolean   :requires_notes,    default: false
      t.boolean   :is_deleted,        default: false

      t.timestamps
    end
  end
end
