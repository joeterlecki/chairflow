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

ActiveRecord::Schema[8.1].define(version: 2026_09_30_185359) do
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

  add_foreign_key "clients", "stylists", column: "preferred_stylist_id"
end
