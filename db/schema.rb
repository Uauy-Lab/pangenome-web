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

ActiveRecord::Schema.define(version: 20150519083424) do

  create_table "assemblies", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "version",     limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

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

  create_table "marker_alias_details", force: :cascade do |t|
    t.string   "alias_detail", limit: 255
    t.string   "description",  limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "marker_names", force: :cascade do |t|
    t.string  "alias",                  limit: 255
    t.integer "marker_id",              limit: 4
    t.integer "marker_alias_detail_id", limit: 4
  end

  add_index "marker_names", ["alias"], name: "index_marker_names_on_alias", using: :btree
  add_index "marker_names", ["marker_alias_detail_id"], name: "index_marker_names_on_marker_alias_detail_id", using: :btree
  add_index "marker_names", ["marker_id"], name: "index_marker_names_on_marker_id", using: :btree

  create_table "marker_sets", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "markers", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "positions_id",  limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "marker_set_id", limit: 4
    t.string   "sequence",      limit: 255
  end

  add_index "markers", ["marker_set_id"], name: "index_markers_on_marker_set_id", using: :btree
  add_index "markers", ["positions_id"], name: "index_markers_on_positions_id", using: :btree

  create_table "scaffolds", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "length",      limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "assembly_id", limit: 4
  end

  add_index "scaffolds", ["assembly_id"], name: "index_scaffolds_on_assembly_id", using: :btree
  add_index "scaffolds", ["name"], name: "index_scaffolds_on_name", using: :btree

  create_table "scaffolds_markers", id: false, force: :cascade do |t|
    t.integer "scaffold_id",          limit: 4
    t.integer "marker_id",            limit: 4
    t.float   "identity",             limit: 24
    t.integer "marker_start",         limit: 4
    t.integer "marker_end",           limit: 4
    t.string  "marker_orientation",   limit: 1
    t.integer "scaffold_start",       limit: 4
    t.integer "scaffold_end",         limit: 4
    t.string  "scaffold_orientation", limit: 1
    t.string  "sequence",             limit: 500
  end

  add_index "scaffolds_markers", ["marker_id"], name: "index_scaffolds_markers_on_marker_id", using: :btree
  add_index "scaffolds_markers", ["marker_start"], name: "index_scaffolds_markers_on_marker_start", using: :btree
  add_index "scaffolds_markers", ["scaffold_id"], name: "index_scaffolds_markers_on_scaffold_id", using: :btree
  add_index "scaffolds_markers", ["scaffold_start"], name: "index_scaffolds_markers_on_scaffold_start", using: :btree

  create_table "species", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "scientific_name", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_foreign_key "marker_names", "markers"
end
