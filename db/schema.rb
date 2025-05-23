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

ActiveRecord::Schema[7.0].define(version: 2025_04_07_200904) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "search_logs", force: :cascade do |t|
    t.bigint "search_query_id", null: false
    t.json "words", null: false
    t.string "ip", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["search_query_id"], name: "index_search_logs_on_search_query_id"
  end

  create_table "search_queries", force: :cascade do |t|
    t.string "query", null: false
    t.text "content", null: false
    t.integer "count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["query"], name: "index_search_queries_on_query", unique: true
  end

  add_foreign_key "search_logs", "search_queries"
end
