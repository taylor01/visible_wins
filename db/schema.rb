# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_13_012323) do
  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "role"
    t.integer "team_id", null: false
    t.string "password_digest"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "okta_sub"
    t.string "employee_id"
    t.string "phone_number"
    t.string "title"
    t.string "department"
    t.string "office_location"
    t.string "manager_email"
    t.date "hire_date"
    t.string "employee_type"
    t.boolean "active", default: true
    t.datetime "profile_completed_at"
    t.index ["active"], name: "index_users_on_active"
    t.index ["department"], name: "index_users_on_department"
    t.index ["employee_id"], name: "index_users_on_employee_id", unique: true
    t.index ["manager_email"], name: "index_users_on_manager_email"
    t.index ["okta_sub"], name: "index_users_on_okta_sub", unique: true
    t.index ["team_id"], name: "index_users_on_team_id"
  end

  create_table "weekly_schedules", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "week_start_date"
    t.string "sunday"
    t.string "monday"
    t.string "tuesday"
    t.string "wednesday"
    t.string "thursday"
    t.string "friday"
    t.string "saturday"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_weekly_schedules_on_user_id"
  end

  add_foreign_key "users", "teams"
  add_foreign_key "weekly_schedules", "users"
end
