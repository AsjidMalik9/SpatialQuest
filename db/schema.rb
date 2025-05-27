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
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "name", null: false
    t.string "status", default: "available"
    t.datetime "collected_at"
    t.datetime "placed_at"
    t.index ["latitude", "longitude"], name: "index_assets_on_quest_id_and_latitude_and_longitude", unique: true
  end

  create_table "quest_assets", force: :cascade do |t|
    t.integer "quest_id", null: false
    t.integer "asset_id", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "status", default: "available"
    t.integer "collected_by_id"
    t.datetime "collected_at"
    t.datetime "placed_at"
    t.string "hint"
    t.text "quest_specific_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_quest_assets_on_asset_id"
    t.index ["collected_by_id"], name: "index_quest_assets_on_collected_by_id"
    t.index ["quest_id", "latitude", "longitude"], name: "index_quest_assets_on_quest_id_and_latitude_and_longitude", unique: true
    t.index ["quest_id"], name: "index_quest_assets_on_quest_id"
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

  add_foreign_key "quest_assets", "assets"
  add_foreign_key "quest_assets", "quests"
  add_foreign_key "quest_assets", "users", column: "collected_by_id"
  add_foreign_key "quest_participants", "quests"
  add_foreign_key "quest_participants", "users"
end
