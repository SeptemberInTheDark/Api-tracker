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

ActiveRecord::Schema[8.0].define(version: 2026_05_28_100400) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "occurrence_overrides", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.date "occurrence_date", null: false
    t.string "status"
    t.string "title"
    t.text "description"
    t.time "due_time"
    t.boolean "cancelled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_occurrence_overrides_on_status"
    t.index ["task_id", "occurrence_date"], name: "index_occurrence_overrides_on_task_id_and_occurrence_date", unique: true
    t.index ["task_id"], name: "index_occurrence_overrides_on_task_id"
  end

  create_table "recurrence_rules", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.string "recurrence_type", null: false
    t.integer "interval"
    t.integer "day_of_month"
    t.date "starts_on", null: false
    t.date "ends_on"
    t.date "specific_dates", default: [], null: false, array: true
    t.string "parity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ends_on"], name: "index_recurrence_rules_on_ends_on"
    t.index ["recurrence_type"], name: "index_recurrence_rules_on_recurrence_type"
    t.index ["starts_on"], name: "index_recurrence_rules_on_starts_on"
    t.index ["task_id"], name: "index_recurrence_rules_on_task_id", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "locked", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_tags_on_lower_name", unique: true
  end

  create_table "task_tags", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_task_tags_on_tag_id"
    t.index ["task_id", "tag_id"], name: "index_task_tags_on_task_id_and_tag_id", unique: true
    t.index ["task_id"], name: "index_task_tags_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.date "due_date", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_date"], name: "index_tasks_on_due_date"
    t.index ["status"], name: "index_tasks_on_status"
  end

  add_foreign_key "occurrence_overrides", "tasks"
  add_foreign_key "recurrence_rules", "tasks"
  add_foreign_key "task_tags", "tags"
  add_foreign_key "task_tags", "tasks"
end
