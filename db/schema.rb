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

ActiveRecord::Schema.define(version: 20170207224456) do

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "quantity",     default: 0
    t.boolean  "scraped",      default: false
    t.date     "release_date"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "image"
    t.index ["name"], name: "index_items_on_name"
  end

  create_table "items_labels", id: false, force: :cascade do |t|
    t.integer "item_id"
    t.integer "label_id"
    t.index ["item_id"], name: "index_items_labels_on_item_id"
    t.index ["label_id"], name: "index_items_labels_on_label_id"
  end

  create_table "labels", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "scraper"
  end

  create_table "links", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_links_on_item_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text     "text"
    t.integer  "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_notes_on_item_id"
  end

end
