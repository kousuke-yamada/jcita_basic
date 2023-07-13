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

ActiveRecord::Schema.define(version: 20230713133820) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "instructor"
    t.datetime "chg_started_at"
    t.datetime "chg_finished_at"
    t.date "approval_date"
    t.datetime "first_started_at"
    t.datetime "first_finished_at"
    t.string "approval_status"
    t.boolean "chg_permission", default: false
    t.datetime "overtime_at"
    t.string "overtime_content"
    t.string "overtime_approval_status"
    t.string "overtime_instructor"
    t.boolean "overtime_chg_permission", default: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "baseno"
    t.string "basename"
    t.string "basekind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lineusers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.index ["email"], name: "index_lineusers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_lineusers_on_reset_password_token", unique: true
  end

  create_table "monthly_attendances", force: :cascade do |t|
    t.string "month"
    t.string "instructor"
    t.string "approval_status"
    t.boolean "chg_permission", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "year"
    t.integer "user_id"
    t.index ["user_id"], name: "index_monthly_attendances_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "affiliation"
    t.datetime "basic_work_time", default: "2023-07-11 22:30:00"
    t.datetime "designated_work_start_time", default: "2023-07-12 00:30:00"
    t.integer "employee_number"
    t.string "uid"
    t.datetime "designated_work_end_time", default: "2023-07-12 09:00:00"
    t.boolean "superior", default: false
    t.float "records1", default: 999.99
    t.float "records2", default: 999.99
    t.float "records3", default: 999.99
    t.float "records4", default: 999.99
    t.float "records5", default: 999.99
    t.float "records6", default: 999.99
    t.float "records7", default: 999.99
    t.float "records8", default: 999.99
    t.float "records9", default: 999.99
    t.string "line_user_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
