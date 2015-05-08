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

ActiveRecord::Schema.define(version: 20150401062505) do

  create_table "chromosomes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "species_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "genetic_maps", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "map_positions", force: :cascade do |t|
    t.integer  "order",          limit: 4
    t.float    "centimorgan",    limit: 24
    t.integer  "genetic_map_id", limit: 4
    t.integer  "marker_id",      limit: 4
    t.integer  "chromosome_id",  limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "map_positions", ["chromosome_id"], name: "index_map_positions_on_chromosome_id", using: :btree
  add_index "map_positions", ["genetic_map_id"], name: "index_map_positions_on_genetic_map_id", using: :btree
  add_index "map_positions", ["marker_id"], name: "index_map_positions_on_marker_id", using: :btree

  create_table "markers", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "positions_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "markers", ["positions_id"], name: "index_markers_on_positions_id", using: :btree

  create_table "species", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "scientific_name", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

end
