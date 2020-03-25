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

ActiveRecord::Schema.define(version: 2020_03_25_020932) do

  create_table "events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "distance", limit: 2, null: false
    t.string "course", null: false
    t.string "stroke", null: false
    t.boolean "relay", default: false, null: false
    t.index ["distance", "course", "stroke", "relay"], name: "index_events_on_distance_and_course_and_stroke_and_relay", unique: true
  end

  create_table "meets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "usms_meet_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["usms_meet_id"], name: "index_meets_on_usms_meet_id", unique: true
  end

  create_table "swimmers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "usms_permanent_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "gender", limit: 1, null: false
    t.date "birth_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["usms_permanent_id"], name: "index_swimmers_on_usms_permanent_id", unique: true
  end

end
