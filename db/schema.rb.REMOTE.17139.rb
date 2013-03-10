# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130304060739) do

  create_table "active_ingredients_brands", :id => false, :force => true do |t|
    t.integer "brand_id"
    t.integer "active_ingredient_id"
  end

  create_table "brands", :force => true do |t|
    t.string "name"
    t.string "mixture"
  end

  create_table "categories", :force => true do |t|
    t.string "name"
  end

  create_table "categories_consumables", :id => false, :force => true do |t|
    t.integer "consumable_id"
    t.integer "category_id"
  end

  create_table "consumables", :force => true do |t|
    t.string "drugbank_id"
    t.string "name"
    t.string "description"
    t.string "indication_text"
    t.string "mechanism"
    t.string "reference"
    t.string "type"
  end

  create_table "interactions", :force => true do |t|
    t.integer "consumable_id"
    t.integer "interactant_id"
    t.string  "description"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "synonyms", :force => true do |t|
    t.integer "consumable_id"
    t.string  "synonym"
  end

end
