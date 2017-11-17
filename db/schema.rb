# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171117133422) do

  create_table "assigned_permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.bigint "permission_id"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "fk_rails_aca282a7fd"
    t.index ["user_id"], name: "fk_rails_324ef26984"
  end

  create_table "attachments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "attachable_id"
    t.string "attachable_type"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file"
  end

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "parent_id"
    t.integer "lft", null: false
    t.integer "rgt", null: false
    t.integer "depth", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.string "google_drive_folder"
    t.index ["lft"], name: "index_categories_on_lft"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["rgt"], name: "index_categories_on_rgt"
  end

  create_table "categories_documents", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "category_id", null: false
    t.bigint "document_id", null: false
    t.index ["category_id", "document_id"], name: "index_categories_documents_on_category_id_and_document_id"
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "content"
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
  end

  create_table "documents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "added_by"
    t.string "name"
    t.boolean "is_valid"
    t.string "content_type"
    t.string "file"
    t.string "google_url"
    t.string "google_id"
    t.text "google_contents"
    t.datetime "google_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "document_updated_on"
    t.boolean "exclude_from_newest", default: false
  end

  create_table "employee_notes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "employee"
    t.bigint "entered_by"
    t.date "note_on"
    t.string "note_type"
    t.string "ip_address"
    t.text "notes"
    t.text "follow_up"
    t.date "follow_up_on"
    t.string "external_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee"], name: "fk_rails_a688637a0d"
    t.index ["entered_by"], name: "fk_rails_60f15ac792"
  end

  create_table "opto_messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "message_name"
    t.datetime "message_at"
    t.integer "department"
    t.integer "lane"
    t.integer "station"
    t.integer "shop_order"
    t.integer "load"
    t.integer "barrel"
    t.text "message"
    t.string "hashed_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "raw_data"
    t.index ["hashed_data"], name: "index_opto_messages_on_hashed_data", unique: true
  end

  create_table "periods", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.date "period_start_date"
    t.date "period_end_date"
    t.boolean "is_closed", default: false
    t.bigint "user_id"
    t.datetime "closed_at"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "permission"
    t.string "description"
    t.integer "label_set"
    t.index ["permission"], name: "index_permissions_on_permission", unique: true
  end

  create_table "reason_codes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "code"
    t.boolean "requires_notes", default: false
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "salt_spray_process_steps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "salt_spray_test_id"
    t.string "name"
    t.string "vat_name"
    t.decimal "temperature", precision: 10
    t.decimal "ph", precision: 10
    t.integer "barrel_rpm"
    t.timestamp "time_in"
    t.timestamp "time_out"
    t.decimal "amp_hours", precision: 10
    t.decimal "target_amp_hours", precision: 10
    t.decimal "thickness", precision: 10
    t.decimal "alloy_percentage", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "salt_spray_tests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "shop_order_number"
    t.integer "load_number"
    t.string "customer"
    t.string "process_code"
    t.string "part_number"
    t.string "sub"
    t.decimal "part_area", precision: 10, scale: 4
    t.decimal "density", precision: 10, scale: 4
    t.integer "white_spec"
    t.integer "red_spec"
    t.integer "dept"
    t.decimal "load_weight", precision: 10, scale: 4
    t.bigint "put_on_by"
    t.datetime "put_on_at"
    t.datetime "pulled_off_at"
    t.bigint "pulled_off_by"
    t.datetime "marked_white_at"
    t.bigint "marked_white_by"
    t.datetime "marked_red_at"
    t.bigint "marked_red_by"
    t.bigint "flagged_by"
    t.boolean "is_sample", default: false
    t.datetime "deleted_at"
    t.bigint "deleted_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["marked_red_by"], name: "fk_rails_818a3fe6c3"
    t.index ["marked_white_by"], name: "fk_rails_eb9b825c87"
    t.index ["put_on_by"], name: "fk_rails_94de30c9f6"
  end

  create_table "shift_notes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "entered_by"
    t.date "note_on"
    t.integer "shift"
    t.string "ip_address"
    t.integer "department"
    t.string "note_type"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "supervisor_notes"
    t.datetime "supervisor_notes_at"
    t.bigint "supervisor_id"
    t.boolean "author_email_needed"
    t.index ["entered_by"], name: "fk_rails_8c4d173e86"
    t.index ["supervisor_id"], name: "fk_rails_bfc751106f"
  end

  create_table "timeclock_records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.string "record_type"
    t.datetime "record_timestamp"
    t.string "submit_type"
    t.string "ip_address"
    t.string "edit_type"
    t.string "edit_ip_address"
    t.bigint "reason_code_id"
    t.string "notes"
    t.boolean "is_locked", default: false
    t.boolean "is_flagged", default: false
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "username"
    t.integer "employee_number"
    t.string "first_name"
    t.string "last_name"
    t.string "suffix"
    t.string "initials"
    t.string "email"
    t.string "pin"
    t.string "current_status", default: "out"
    t.string "background_color"
    t.string "text_color"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["employee_number"], name: "index_users_on_employee_number", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "assigned_permissions", "permissions"
  add_foreign_key "assigned_permissions", "users"
  add_foreign_key "employee_notes", "users", column: "employee"
  add_foreign_key "employee_notes", "users", column: "entered_by"
  add_foreign_key "salt_spray_tests", "users", column: "marked_red_by"
  add_foreign_key "salt_spray_tests", "users", column: "marked_white_by"
  add_foreign_key "salt_spray_tests", "users", column: "put_on_by"
  add_foreign_key "shift_notes", "users", column: "entered_by"
  add_foreign_key "shift_notes", "users", column: "supervisor_id"
end
