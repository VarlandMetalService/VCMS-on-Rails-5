class CreatePeriods < ActiveRecord::Migration[5.1]
  def change
    create_table :periods do |t|
      t.date        :period_start_date
      t.date        :period_end_date
      t.boolean     :is_closed,               default: false
      t.bigint      :user_id
      t.datetime    :closed_at
      t.string      :ip_address
      t.timestamps
    end
  end
end
