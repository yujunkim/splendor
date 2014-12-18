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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141117054256) do

  create_table "cards", force: true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "point",      default: 0
    t.integer  "diamond",    default: 0
    t.integer  "sapphire",   default: 0
    t.integer  "emerald",    default: 0
    t.integer  "ruby",       default: 0
    t.integer  "onyx",       default: 0
    t.integer  "card_grade", default: 1
    t.string   "jewel_type"
    t.boolean  "reserved",   default: false
    t.boolean  "revealed",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_user_associations", force: true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "order",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", force: true do |t|
    t.integer  "current_turn_user_id"
    t.integer  "winner_id"
    t.string   "order_user_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jewel_chips", force: true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.string   "jewel_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nobles", force: true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "point",      default: 0
    t.integer  "diamond",    default: 0
    t.integer  "sapphire",   default: 0
    t.integer  "emerald",    default: 0
    t.integer  "ruby",       default: 0
    t.integer  "onyx",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "auth_token"
    t.string   "name"
    t.string   "color"
    t.string   "home"
    t.boolean  "robot",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
