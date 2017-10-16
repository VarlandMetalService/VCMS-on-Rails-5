class CreateTimeclockRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :timeclock_records do |t|
      t.bigint    :user_id
      t.string    :record_type
      t.datetime  :record_timestamp
      t.string    :submit_type
      t.string    :ip_address
      t.string    :edit_type
      t.string    :edit_ip_address
      t.bigint    :reason_code_id
      t.string    :notes
      t.boolean   :is_locked
      t.boolean   :is_flagged

      t.timestamps
    end
  end
end
