class CreateEmployeeNotes < ActiveRecord::Migration[5.1]

  def change
    create_table :employee_notes do |t|
      t.bigint      :employee
      t.bigint      :entered_by
      t.date        :note_on
      t.string      :note_type
      t.string      :ip_address
      t.text        :notes
      t.text        :follow_up,       default: nil
      t.date        :follow_up_on,    default: nil
      t.string      :external_key,    default: nil
      t.timestamps
    end

    add_foreign_key :employee_notes, :users, column: :employee
    add_foreign_key :employee_notes, :users, column: :entered_by
  end

end
