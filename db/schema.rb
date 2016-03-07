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

ActiveRecord::Schema.define(version: 20160307181739) do

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

  create_table "chromosomes_scaffolds", id: false, force: :cascade do |t|
    t.integer "chromosome_id", limit: 4, null: false
    t.integer "scaffold_id",   limit: 4, null: false
  end

  add_index "chromosomes_scaffolds", ["chromosome_id", "scaffold_id"], name: "index_chromosomes_scaffolds_on_chromosome_id_and_scaffold_id", using: :btree
  add_index "chromosomes_scaffolds", ["scaffold_id", "chromosome_id"], name: "index_chromosomes_scaffolds_on_scaffold_id_and_chromosome_id", using: :btree

  create_table "deleted_scaffolds", force: :cascade do |t|
    t.integer  "scaffold_id", limit: 4
    t.integer  "library_id",  limit: 4
    t.float    "cov_avg",     limit: 24
    t.float    "cov_sd",      limit: 24
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "deleted_scaffolds", ["library_id"], name: "index_deleted_scaffolds_on_library_id", using: :btree
  add_index "deleted_scaffolds", ["scaffold_id"], name: "index_deleted_scaffolds_on_scaffold_id", using: :btree

  create_table "gene_sets", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "gene_sets", ["name"], name: "index_gene_sets_on_name", using: :btree

  create_table "genes", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "cdna",        limit: 255
    t.string   "possition",   limit: 255
    t.string   "gene",        limit: 255
    t.string   "transcript",  limit: 255
    t.integer  "gene_set_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.text     "description", limit: 65535
  end

  add_index "genes", ["gene"], name: "index_genes_on_gene", using: :btree
  add_index "genes", ["gene_set_id"], name: "index_genes_on_gene_set_id", using: :btree
  add_index "genes", ["name"], name: "index_genes_on_name", using: :btree
  add_index "genes", ["transcript"], name: "index_genes_on_transcript", using: :btree

  create_table "genetic_maps", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "libraries", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.integer  "line_id",     limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "libraries", ["line_id"], name: "index_libraries_on_line_id", using: :btree

  create_table "lines", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "mutant",      limit: 1
    t.integer  "species_id",  limit: 4
    t.integer  "wildtype_id", limit: 4
  end

  add_index "lines", ["name"], name: "index_lines_on_name", using: :btree
  add_index "lines", ["species_id"], name: "index_lines_on_species_id", using: :btree

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

  create_table "mutation_consequences", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "mutation_consequences", ["name"], name: "index_mutation_consequences_on_name", using: :btree

  create_table "mutations", force: :cascade do |t|
    t.string   "het_hom",    limit: 255
    t.integer  "wt_cov",     limit: 4
    t.integer  "mut_cov",    limit: 4
    t.string   "confidence", limit: 255
    t.integer  "gene_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "SNP_id",     limit: 4
    t.integer  "library_id", limit: 4
  end

  add_index "mutations", ["SNP_id", "library_id"], name: "index_mutations_on_snp_id_and_library_id", unique: true, using: :btree
  add_index "mutations", ["SNP_id"], name: "index_mutations_on_SNP_id", using: :btree
  add_index "mutations", ["gene_id"], name: "index_mutations_on_gene_id", using: :btree
  add_index "mutations", ["library_id"], name: "index_mutations_on_library_id", using: :btree

  create_table "scaffolds", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "length",      limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "assembly_id", limit: 4
    t.string   "chromosome",  limit: 255
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

  create_table "snps", force: :cascade do |t|
    t.integer  "scaffold_id", limit: 4
    t.integer  "position",    limit: 4
    t.string   "ref",         limit: 1
    t.string   "wt",          limit: 1
    t.string   "alt",         limit: 1
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "snps", ["position"], name: "index_snps_on_position", using: :btree
  add_index "snps", ["scaffold_id", "position", "wt", "alt"], name: "index_snps_on_scaffold_id_and_position_and_wt_and_alt", unique: true, using: :btree
  add_index "snps", ["scaffold_id"], name: "index_snps_on_scaffold_id", using: :btree

  create_table "species", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "scientific_name", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_foreign_key "deleted_scaffolds", "libraries"
  add_foreign_key "deleted_scaffolds", "scaffolds"
  add_foreign_key "libraries", "lines"
  add_foreign_key "lines", "species"
  add_foreign_key "marker_names", "markers"
  add_foreign_key "mutations", "SNPs"
  add_foreign_key "mutations", "genes"
  add_foreign_key "mutations", "libraries"
  add_foreign_key "snps", "scaffolds"
end
