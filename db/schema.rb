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

ActiveRecord::Schema.define(version: 20170918185340) do

  create_table "assigned_permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.bigint "permission_id"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "fk_rails_aca282a7fd"
    t.index ["user_id"], name: "fk_rails_324ef26984"
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

  create_table "permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "permission"
    t.string "description"
    t.integer "label_set"
    t.index ["permission"], name: "index_permissions_on_permission", unique: true
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
end
