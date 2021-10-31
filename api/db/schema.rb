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

ActiveRecord::Schema.define(version: 2020_12_29_140145) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "quantity", default: 0
    t.boolean "scraped", default: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.datetime "deleted_at"
    t.integer "user_id"
    t.integer "list_id"
    t.integer "status", default: 0
    t.float "rating"
    t.string "recommended_by"
    t.date "first_done_at"
    t.string "language"
    t.string "original_name"
    t.index ["deleted_at"], name: "index_items_on_deleted_at"
    t.index ["first_done_at"], name: "index_items_on_first_done_at"
    t.index ["language"], name: "index_items_on_language"
    t.index ["list_id"], name: "index_items_on_list_id"
    t.index ["name"], name: "index_items_on_name"
    t.index ["original_name"], name: "index_items_on_original_name"
    t.index ["rating"], name: "index_items_on_rating"
    t.index ["recommended_by"], name: "index_items_on_recommended_by"
    t.index ["status"], name: "index_items_on_status"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "items_tags", id: false, force: :cascade do |t|
    t.integer "item_id"
    t.integer "tag_id"
    t.index ["item_id"], name: "index_items_tags_on_item_id"
    t.index ["tag_id"], name: "index_items_tags_on_tag_id"
  end

  create_table "links", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_links_on_item_id"
  end

  create_table "lists", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "scraper"
    t.string "fa_icon"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.text "text"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_notes_on_item_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["name"], name: "index_tags_on_name"
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  add_foreign_key "items", "users"
  add_foreign_key "links", "items"
  add_foreign_key "lists", "users"
  add_foreign_key "notes", "items"
  add_foreign_key "tags", "users"
end
