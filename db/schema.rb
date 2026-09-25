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

ActiveRecord::Schema[8.1].define(version: 2026_09_25_040000) do
  create_table "appointments", force: :cascade do |t|
    t.integer "stylist_id", null: false
    t.integer "client_id", null: false
    t.string "service", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_appointments_on_client_id"
    t.index ["stylist_id", "starts_at", "ends_at"], name: "index_appointments_on_stylist_id_and_starts_at_and_ends_at"
    t.index ["stylist_id"], name: "index_appointments_on_stylist_id"
    t.check_constraint "ends_at > starts_at", name: "positive_appointment_duration"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "phone"
    t.integer "preferred_stylist_id"
    t.index ["preferred_stylist_id"], name: "index_clients_on_preferred_stylist_id"
  end

  create_table "scheduled_shifts", force: :cascade do |t|
    t.integer "stylist_id", null: false
    t.date "date", null: false
    t.boolean "closed", default: false, null: false
    t.string "opens_at", default: "09:00", null: false
    t.string "closes_at", default: "18:00", null: false
    t.string "break_starts_at"
    t.string "break_ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stylist_id", "date"], name: "index_scheduled_shifts_on_stylist_id_and_date", unique: true
    t.index ["stylist_id"], name: "index_scheduled_shifts_on_stylist_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.integer "default_duration", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_services_on_name", unique: true
  end

  create_table "stylists", force: :cascade do |t|
    t.string "name", null: false
    t.string "color", default: "sage", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "time_offs", force: :cascade do |t|
    t.integer "stylist_id", null: false
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stylist_id", "starts_on", "ends_on"], name: "index_time_offs_on_stylist_id_and_starts_on_and_ends_on"
    t.index ["stylist_id"], name: "index_time_offs_on_stylist_id"
    t.check_constraint "ends_on >= starts_on", name: "time_off_dates_in_order"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "working_days", force: :cascade do |t|
    t.integer "stylist_id", null: false
    t.integer "weekday", null: false
    t.boolean "closed", default: false, null: false
    t.string "opens_at", default: "09:00", null: false
    t.string "closes_at", default: "18:00", null: false
    t.string "break_starts_at"
    t.string "break_ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stylist_id", "weekday"], name: "index_working_days_on_stylist_id_and_weekday", unique: true
    t.index ["stylist_id"], name: "index_working_days_on_stylist_id"
  end

  add_foreign_key "appointments", "clients"
  add_foreign_key "appointments", "stylists"
  add_foreign_key "clients", "stylists", column: "preferred_stylist_id", on_delete: :nullify
  add_foreign_key "scheduled_shifts", "stylists"
  add_foreign_key "time_offs", "stylists"
  add_foreign_key "working_days", "stylists"
end
