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

  add_index "cards", ["game_id"], name: "index_cards_on_game_id", using: :btree
  add_index "cards", ["jewel_type"], name: "index_cards_on_jewel_type", using: :btree
  add_index "cards", ["reserved"], name: "index_cards_on_reserved", using: :btree
  add_index "cards", ["revealed"], name: "index_cards_on_revealed", using: :btree
  add_index "cards", ["user_id"], name: "index_cards_on_user_id", using: :btree

  create_table "game_user_associations", force: true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "order",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "game_user_associations", ["game_id"], name: "index_game_user_associations_on_game_id", using: :btree
  add_index "game_user_associations", ["order"], name: "index_game_user_associations_on_order", using: :btree
  add_index "game_user_associations", ["user_id"], name: "index_game_user_associations_on_user_id", using: :btree

  create_table "games", force: true do |t|
    t.integer  "current_turn_user_id"
    t.integer  "winner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "games", ["current_turn_user_id"], name: "index_games_on_current_turn_user_id", using: :btree
  add_index "games", ["winner_id"], name: "index_games_on_winner_id", using: :btree

  create_table "jewel_chips", force: true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.string   "jewel_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "jewel_chips", ["game_id"], name: "index_jewel_chips_on_game_id", using: :btree
  add_index "jewel_chips", ["jewel_type"], name: "index_jewel_chips_on_jewel_type", using: :btree
  add_index "jewel_chips", ["user_id"], name: "index_jewel_chips_on_user_id", using: :btree

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

  add_index "nobles", ["game_id"], name: "index_nobles_on_game_id", using: :btree
  add_index "nobles", ["user_id"], name: "index_nobles_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "auth_token"
    t.string   "name"
    t.string   "color"
    t.string   "home"
    t.boolean  "robot",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", using: :btree
  add_index "users", ["robot"], name: "index_users_on_robot", using: :btree

end
