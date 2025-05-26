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

ActiveRecord::Schema[7.1].define(version: 2025_05_26_112531) do
  create_table "assets", force: :cascade do |t|
    t.integer "quest_id", null: false
    t.integer "user_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.index ["quest_id"], name: "index_assets_on_quest_id"
    t.index ["user_id"], name: "index_assets_on_user_id"
  end

  create_table "quest_participants", force: :cascade do |t|
    t.integer "quest_id", null: false
    t.integer "user_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quest_id"], name: "index_quest_participants_on_quest_id"
    t.index ["user_id"], name: "index_quest_participants_on_user_id"
  end

  create_table "quests", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.text "boundary"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
  end

  add_foreign_key "assets", "quests"
  add_foreign_key "assets", "users"
  add_foreign_key "quest_participants", "quests"
  add_foreign_key "quest_participants", "users"
end
