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

ActiveRecord::Schema[8.1].define(version: 2026_09_30_185655) do
  create_table "appointment_services", force: :cascade do |t|
    t.integer "appointment_id", null: false
    t.integer "service_id", null: false
    t.integer "position", null: false
    t.integer "duration_minutes", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_appointment_services_on_appointment_id"
    t.index ["service_id"], name: "index_appointment_services_on_service_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "stylist_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "status", default: "booked", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_appointments_on_client_id"
    t.index ["stylist_id", "starts_at"], name: "index_appointments_on_stylist_id_and_starts_at"
    t.index ["stylist_id"], name: "index_appointments_on_stylist_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.string "phone"
    t.integer "preferred_stylist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["preferred_stylist_id"], name: "index_clients_on_preferred_stylist_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.integer "default_duration_minutes", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stylists", force: :cascade do |t|
    t.string "name", null: false
    t.string "swatch", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "appointment_services", "appointments"
  add_foreign_key "appointment_services", "services"
  add_foreign_key "appointments", "clients"
  add_foreign_key "appointments", "stylists"
  add_foreign_key "clients", "stylists", column: "preferred_stylist_id"
end
