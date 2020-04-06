# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_06_004535) do

  create_table "age_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "gender", limit: 1, null: false
    t.integer "start_age", limit: 2, null: false
    t.integer "end_age", limit: 2
    t.boolean "relay", default: false, null: false
    t.index ["gender", "start_age", "relay"], name: "index_age_groups_on_gender_and_start_age_and_relay", unique: true
  end

  create_table "events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "distance", limit: 2, null: false
    t.string "course", null: false
    t.string "stroke", null: false
    t.boolean "relay", default: false, null: false
    t.index ["distance", "course", "stroke", "relay"], name: "index_events_on_distance_and_course_and_stroke_and_relay", unique: true
  end

  create_table "meets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "usms_meet_id", null: false
    t.string "name"
    t.integer "year", limit: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["usms_meet_id"], name: "index_meets_on_usms_meet_id", unique: true
    t.index ["year"], name: "index_meets_on_year"
  end

  create_table "results", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "meet_id", null: false
    t.bigint "event_id", null: false
    t.bigint "age_group_id", null: false
    t.bigint "swimmer_id", null: false
    t.integer "time_ms", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["age_group_id"], name: "index_results_on_age_group_id"
    t.index ["event_id"], name: "index_results_on_event_id"
    t.index ["meet_id"], name: "index_results_on_meet_id"
    t.index ["swimmer_id"], name: "index_results_on_swimmer_id"
    t.index ["time_ms"], name: "index_results_on_time_ms"
  end

  create_table "swimmer_aliases", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.bigint "swimmer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["last_name", "first_name"], name: "index_swimmer_aliases_on_last_name_and_first_name", unique: true
    t.index ["swimmer_id"], name: "index_swimmer_aliases_on_swimmer_id"
  end

  create_table "swimmers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "usms_permanent_id", null: false
    t.string "first_name"
    t.string "middle_initial", limit: 1
    t.string "last_name"
    t.string "gender", limit: 1
    t.date "birth_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["usms_permanent_id"], name: "index_swimmers_on_usms_permanent_id", unique: true
  end

end
