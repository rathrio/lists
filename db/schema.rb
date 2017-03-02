# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170302151706) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "quantity",    default: 0
    t.boolean  "scraped",     default: false
    t.date     "date"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "image"
    t.datetime "deleted_at"
    t.integer  "user_id"
    t.index ["deleted_at"], name: "index_items_on_deleted_at", using: :btree
    t.index ["name"], name: "index_items_on_name", using: :btree
    t.index ["user_id"], name: "index_items_on_user_id", using: :btree
  end

  create_table "items_labels", id: false, force: :cascade do |t|
    t.integer "item_id"
    t.integer "label_id"
    t.index ["item_id"], name: "index_items_labels_on_item_id", using: :btree
    t.index ["label_id"], name: "index_items_labels_on_label_id", using: :btree
  end

  create_table "items_tags", id: false, force: :cascade do |t|
    t.integer "item_id"
    t.integer "tag_id"
    t.index ["item_id"], name: "index_items_tags_on_item_id", using: :btree
    t.index ["tag_id"], name: "index_items_tags_on_tag_id", using: :btree
  end

  create_table "labels", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "scraper"
    t.string   "fa_icon"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.index ["user_id"], name: "index_labels_on_user_id", using: :btree
  end

  create_table "links", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_links_on_item_id", using: :btree
  end

  create_table "notes", force: :cascade do |t|
    t.text     "text"
    t.integer  "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_notes_on_item_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.index ["name"], name: "index_tags_on_name", using: :btree
    t.index ["user_id"], name: "index_tags_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "email",                          null: false
    t.string   "encrypted_password", limit: 128, null: false
    t.string   "confirmation_token", limit: 128
    t.string   "remember_token",     limit: 128, null: false
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["remember_token"], name: "index_users_on_remember_token", using: :btree
  end

  add_foreign_key "items", "users"
  add_foreign_key "labels", "users"
  add_foreign_key "links", "items"
  add_foreign_key "notes", "items"
  add_foreign_key "tags", "users"
end
