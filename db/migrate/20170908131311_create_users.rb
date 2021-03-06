class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string          :username
      t.integer         :employee_number
      t.string          :first_name
      t.string          :last_name
      t.string          :suffix, default: nil
      t.string          :initials
      t.string          :email
      t.string          :pin
      t.integer         :role, default: 3
      t.string          :current_status, default: 'out'
      t.string          :background_color
      t.string          :text_color
      t.boolean         :is_active, default: true

      t.timestamps       null: false
    end

    add_index :users, :username, unique: true
    add_index :users, :employee_number, unique: true
    add_index :users, :email, unique: true

  end
end
