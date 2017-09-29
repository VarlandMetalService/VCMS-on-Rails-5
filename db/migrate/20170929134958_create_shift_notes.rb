class CreateShiftNotes < ActiveRecord::Migration[5.1]

  def change

    create_table :shift_notes do |t|
      t.bigint      :entered_by
      t.date        :note_on
      t.integer     :shift
      t.string      :ip_address
      t.integer     :department,          default: nil
      t.string      :note_type,           default: nil
      t.text        :notes
      t.timestamps                        null: false
      t.text        :supervisor_notes,    default: nil
      t.datetime    :supervisor_notes_at
      t.bigint      :supervisor_id
      t.boolean     :author_email_needed
    end

    add_foreign_key :shift_notes, :users, column: :entered_by
    add_foreign_key :shift_notes, :users, column: :supervisor_id

  end

end
