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

ActiveRecord::Schema[8.1].define(version: 2026_10_10_090001) do
  create_table "components", force: :cascade do |t|
    t.string "name", null: false
    t.string "status", default: "operational", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_components_on_name", unique: true
  end

  create_table "incident_updates", force: :cascade do |t|
    t.integer "incident_id", null: false
    t.string "status", null: false
    t.text "body", null: false
    t.datetime "posted_at", null: false
    t.index ["incident_id"], name: "index_incident_updates_on_incident_id"
  end

  create_table "incidents", force: :cascade do |t|
    t.string "title", null: false
    t.string "status", default: "investigating", null: false
    t.string "severity", default: "minor", null: false
    t.datetime "started_at", null: false
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["started_at"], name: "index_incidents_on_started_at"
  end

  create_table "maintenances", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", default: "", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ends_at"], name: "index_maintenances_on_ends_at"
  end

  add_foreign_key "incident_updates", "incidents", on_delete: :cascade
end
