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

ActiveRecord::Schema.define(version: 2021_03_18_204640) do

  create_table "alignment_sets", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "alignments_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_alignment_sets_on_name"
  end

  create_table "alignments", charset: "utf8", force: :cascade do |t|
    t.bigint "alignment_set_id"
    t.bigint "region_id"
    t.bigint "feature_type_id"
    t.bigint "assembly_id"
    t.float "pident"
    t.integer "length"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "align_id"
    t.index ["alignment_set_id"], name: "index_alignments_on_alignment_set_id"
    t.index ["assembly_id"], name: "index_alignments_on_assembly_id"
    t.index ["feature_type_id"], name: "index_alignments_on_feature_type_id"
    t.index ["region_id"], name: "index_alignments_on_region_id"
  end

  create_table "assemblies", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "version"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_cannonical", default: false
    t.boolean "is_pseudomolecule", default: false
    t.index ["name"], name: "index_assemblies_on_name"
  end

  create_table "biotypes", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_biotypes_on_name"
  end

  create_table "chromosomes", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "species_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_chromosomes_on_name"
    t.index ["species_id"], name: "index_chromosomes_on_species_id"
  end

  create_table "chromosomes_scaffolds", id: false, charset: "utf8", force: :cascade do |t|
    t.bigint "chromosome_id", null: false
    t.bigint "scaffold_id", null: false
    t.index ["chromosome_id", "scaffold_id"], name: "index_chromosomes_scaffolds_on_chromosome_id_and_scaffold_id"
    t.index ["scaffold_id", "chromosome_id"], name: "index_chromosomes_scaffolds_on_scaffold_id_and_chromosome_id"
  end

  create_table "deleted_scaffolds", charset: "utf8", force: :cascade do |t|
    t.bigint "scaffold_id"
    t.bigint "library_id"
    t.float "cov_avg"
    t.float "cov_sd"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["library_id"], name: "index_deleted_scaffolds_on_library_id"
    t.index ["scaffold_id", "library_id"], name: "index_deleted_scaffolds_on_scaffold_id_and_library_id", unique: true
    t.index ["scaffold_id"], name: "index_deleted_scaffolds_on_scaffold_id"
  end

  create_table "effect_types", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "effects", charset: "utf8", force: :cascade do |t|
    t.bigint "snp_id"
    t.bigint "feature_id"
    t.bigint "effect_type_id"
    t.integer "cdna_position"
    t.integer "cds_position"
    t.string "amino_acids", limit: 8
    t.string "codons", limit: 7
    t.float "sift_score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "protein_position"
    t.index ["effect_type_id"], name: "index_effects_on_effect_type_id"
    t.index ["feature_id"], name: "index_effects_on_feature_id"
    t.index ["snp_id"], name: "index_effects_on_snp_id"
  end

  create_table "feature_mapping_sets", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "mapping_count"
    t.index ["name"], name: "index_feature_mapping_sets_on_name"
  end

  create_table "feature_mappings", charset: "utf8", force: :cascade do |t|
    t.bigint "assembly_id", null: false
    t.bigint "feature_id", null: false
    t.bigint "chromosome_id", null: false
    t.bigint "feature_mapping_set_id", null: false
    t.bigint "other_feature"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assembly_id"], name: "index_feature_mappings_on_assembly_id"
    t.index ["chromosome_id"], name: "index_feature_mappings_on_chromosome_id"
    t.index ["feature_id"], name: "index_feature_mappings_on_feature_id"
    t.index ["feature_mapping_set_id"], name: "index_feature_mappings_on_feature_mapping_set_id"
    t.index ["other_feature"], name: "fk_rails_d895db1091"
  end

  create_table "feature_types", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_feature_types_on_name"
  end

  create_table "features", charset: "utf8", force: :cascade do |t|
    t.bigint "region_id"
    t.bigint "feature_type_id"
    t.bigint "biotype_id"
    t.bigint "parent_id"
    t.string "orientation", limit: 1
    t.integer "frame"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.index ["biotype_id"], name: "index_features_on_biotype_id"
    t.index ["feature_type_id"], name: "index_features_on_feature_type_id"
    t.index ["parent_id"], name: "fk_rails_95517896e1"
    t.index ["region_id"], name: "index_features_on_region_id"
  end

  create_table "gene_sets", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_gene_sets_on_name"
  end

  create_table "genes", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "cdna"
    t.string "position"
    t.string "gene"
    t.string "transcript"
    t.bigint "gene_set_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.bigint "feature_id"
    t.index ["feature_id"], name: "index_genes_on_feature_id"
    t.index ["gene"], name: "index_genes_on_gene"
    t.index ["gene_set_id"], name: "index_genes_on_gene_set_id"
    t.index ["name"], name: "index_genes_on_name"
    t.index ["transcript"], name: "index_genes_on_transcript"
  end

  create_table "genetic_maps", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "haplotype_blocks", charset: "utf8", force: :cascade do |t|
    t.integer "block_no"
    t.bigint "region_id"
    t.bigint "assembly_id"
    t.bigint "first_feature"
    t.bigint "last_feature"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "haplotype_set_id", null: false
    t.bigint "reference_assembly"
    t.boolean "in_reciprocal"
    t.index ["assembly_id"], name: "index_haplotype_blocks_on_assembly_id"
    t.index ["first_feature"], name: "fk_rails_122a0e66e2"
    t.index ["haplotype_set_id"], name: "index_haplotype_blocks_on_haplotype_set_id"
    t.index ["last_feature"], name: "fk_rails_a0464c8b4a"
    t.index ["reference_assembly"], name: "fk_rails_6ef54a9b47"
    t.index ["region_id"], name: "index_haplotype_blocks_on_region_id"
  end

  create_table "haplotype_sets", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "kmer_analyses", charset: "utf8", force: :cascade do |t|
    t.bigint "line_id", null: false
    t.bigint "assembly_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.text "description"
    t.bigint "library_id"
    t.index ["assembly_id"], name: "index_kmer_analyses_on_assembly_id"
    t.index ["library_id"], name: "index_kmer_analyses_on_library_id"
    t.index ["line_id"], name: "index_kmer_analyses_on_line_id"
  end

  create_table "kmer_analyses_score_types", id: false, charset: "utf8", force: :cascade do |t|
    t.bigint "kmer_analysis_id", null: false
    t.bigint "score_type_id", null: false
  end

  create_table "libraries", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "line_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_id"], name: "index_libraries_on_line_id"
  end

  create_table "lines", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "mutant", limit: 1
    t.bigint "species_id"
    t.integer "wildtype_id"
    t.index ["name"], name: "index_lines_on_name"
    t.index ["species_id"], name: "index_lines_on_species_id"
  end

  create_table "map_positions", charset: "utf8", force: :cascade do |t|
    t.integer "order"
    t.float "centimorgan"
    t.bigint "genetic_map_id"
    t.bigint "marker_id"
    t.bigint "chromosome_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chromosome_id"], name: "index_map_positions_on_chromosome_id"
    t.index ["genetic_map_id"], name: "index_map_positions_on_genetic_map_id"
    t.index ["marker_id"], name: "index_map_positions_on_marker_id"
  end

  create_table "marker_alias_details", charset: "utf8", force: :cascade do |t|
    t.string "alias_detail"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "marker_names", charset: "utf8", force: :cascade do |t|
    t.string "alias"
    t.bigint "marker_id"
    t.bigint "marker_alias_detail_id"
    t.index ["alias"], name: "index_marker_names_on_alias"
    t.index ["marker_alias_detail_id"], name: "index_marker_names_on_marker_alias_detail_id"
    t.index ["marker_id"], name: "index_marker_names_on_marker_id"
  end

  create_table "marker_sets", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "markers", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "positions_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "marker_set_id"
    t.string "sequence"
    t.index ["marker_set_id"], name: "index_markers_on_marker_set_id"
    t.index ["positions_id"], name: "index_markers_on_positions_id"
  end

  create_table "multi_maps", charset: "utf8", force: :cascade do |t|
    t.bigint "snp_id"
    t.bigint "scaffold_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["scaffold_id", "snp_id"], name: "index_multi_maps_on_scaffold_id_and_snp_id", unique: true
    t.index ["scaffold_id"], name: "index_multi_maps_on_scaffold_id"
    t.index ["snp_id"], name: "index_multi_maps_on_snp_id"
  end

  create_table "mutation_consequences", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_mutation_consequences_on_name"
  end

  create_table "mutations", charset: "utf8", force: :cascade do |t|
    t.string "het_hom"
    t.integer "wt_cov"
    t.integer "mut_cov"
    t.string "confidence"
    t.bigint "gene_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "snp_id"
    t.bigint "library_id"
    t.integer "total_cov"
    t.integer "mm_count"
    t.string "hom_corrected", limit: 1
    t.index ["gene_id"], name: "index_mutations_on_gene_id"
    t.index ["library_id"], name: "index_mutations_on_library_id"
    t.index ["snp_id", "library_id"], name: "index_mutations_on_snp_id_and_library_id", unique: true
    t.index ["snp_id"], name: "index_mutations_on_snp_id"
  end

  create_table "primer_types", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "primers", charset: "utf8", force: :cascade do |t|
    t.bigint "snp_id"
    t.bigint "primer_type_id"
    t.string "orientation", limit: 1
    t.string "wt"
    t.string "alt"
    t.string "common"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["primer_type_id"], name: "index_primers_on_primer_type_id"
    t.index ["snp_id"], name: "index_primers_on_snp_id"
  end

  create_table "region_coverages", charset: "utf8", force: :cascade do |t|
    t.bigint "library_id"
    t.bigint "region_id"
    t.float "coverage"
    t.string "hom", limit: 1
    t.string "het", limit: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["library_id"], name: "index_region_coverages_on_library_id"
    t.index ["region_id"], name: "index_region_coverages_on_region_id"
  end

  create_table "region_scores", charset: "utf8", force: :cascade do |t|
    t.bigint "region_id", null: false
    t.bigint "score_types_id"
    t.integer "value"
    t.bigint "kmer_analysis_id"
    t.index ["kmer_analysis_id"], name: "index_region_scores_on_kmer_analysis_id"
    t.index ["region_id"], name: "index_region_scores_on_region_id"
    t.index ["score_types_id"], name: "index_region_scores_on_score_types_id"
  end

  create_table "regions", charset: "utf8", force: :cascade do |t|
    t.bigint "scaffold_id"
    t.integer "start"
    t.integer "end"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["scaffold_id", "start", "end"], name: "index_regions_on_scaffold_id_and_start_and_end", unique: true
    t.index ["scaffold_id"], name: "index_regions_on_scaffold_id"
  end

  create_table "scaffold_mappings", charset: "utf8", force: :cascade do |t|
    t.bigint "scaffold_id"
    t.integer "coordinate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "other_coordinate"
    t.integer "other_scaffold_id"
    t.index ["scaffold_id"], name: "index_scaffold_mappings_on_scaffold_id"
  end

  create_table "scaffold_maps", charset: "utf8", force: :cascade do |t|
    t.bigint "scaffold_id"
    t.bigint "chromosome_id"
    t.bigint "genetic_map_id"
    t.float "cm"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chromosome_id"], name: "index_scaffold_maps_on_chromosome_id"
    t.index ["cm"], name: "index_scaffold_maps_on_cm"
    t.index ["genetic_map_id"], name: "index_scaffold_maps_on_genetic_map_id"
    t.index ["scaffold_id"], name: "index_scaffold_maps_on_scaffold_id"
  end

  create_table "scaffolds", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "length"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "assembly_id"
    t.integer "chromosome"
    t.index ["assembly_id"], name: "index_scaffolds_on_assembly_id"
    t.index ["name"], name: "index_scaffolds_on_name"
  end

  create_table "scaffolds_markers", id: false, charset: "utf8", force: :cascade do |t|
    t.bigint "scaffold_id"
    t.bigint "marker_id"
    t.float "identity"
    t.integer "marker_start"
    t.integer "marker_end"
    t.string "marker_orientation", limit: 1
    t.integer "scaffold_start"
    t.integer "scaffold_end"
    t.string "scaffold_orientation", limit: 1
    t.string "sequence", limit: 500
    t.index ["marker_id"], name: "index_scaffolds_markers_on_marker_id"
    t.index ["marker_start"], name: "index_scaffolds_markers_on_marker_start"
    t.index ["scaffold_id"], name: "index_scaffolds_markers_on_scaffold_id"
    t.index ["scaffold_start"], name: "index_scaffolds_markers_on_scaffold_start"
  end

  create_table "score_types", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "mantisa"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_score_types_on_name"
  end

  create_table "snps", charset: "utf8", force: :cascade do |t|
    t.bigint "scaffold_id"
    t.integer "position"
    t.string "ref", limit: 1
    t.string "wt", limit: 8
    t.string "alt", limit: 8
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "species_id"
    t.index ["position"], name: "index_snps_on_position"
    t.index ["scaffold_id", "species_id", "position", "wt", "alt"], name: "snp_species_index", unique: true
    t.index ["scaffold_id"], name: "index_snps_on_scaffold_id"
    t.index ["species_id"], name: "index_snps_on_species_id"
  end

  create_table "species", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "scientific_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_species_on_name"
  end

  add_foreign_key "alignments", "alignment_sets"
  add_foreign_key "alignments", "assemblies"
  add_foreign_key "alignments", "feature_types"
  add_foreign_key "alignments", "regions"
  add_foreign_key "deleted_scaffolds", "libraries"
  add_foreign_key "deleted_scaffolds", "scaffolds"
  add_foreign_key "effects", "effect_types"
  add_foreign_key "feature_mappings", "assemblies"
  add_foreign_key "feature_mappings", "chromosomes"
  add_foreign_key "feature_mappings", "feature_mapping_sets"
  add_foreign_key "feature_mappings", "features"
  add_foreign_key "feature_mappings", "features", column: "other_feature"
  add_foreign_key "features", "biotypes"
  add_foreign_key "features", "feature_types"
  add_foreign_key "features", "features", column: "parent_id"
  add_foreign_key "features", "regions"
  add_foreign_key "genes", "features"
  add_foreign_key "genes", "gene_sets"
  add_foreign_key "haplotype_blocks", "assemblies"
  add_foreign_key "haplotype_blocks", "assemblies", column: "reference_assembly"
  add_foreign_key "haplotype_blocks", "features", column: "first_feature"
  add_foreign_key "haplotype_blocks", "features", column: "last_feature"
  add_foreign_key "haplotype_blocks", "haplotype_sets"
  add_foreign_key "haplotype_blocks", "regions"
  add_foreign_key "kmer_analyses", "assemblies"
  add_foreign_key "kmer_analyses", "lines"
  add_foreign_key "libraries", "lines"
  add_foreign_key "libraries", "lines"
  add_foreign_key "lines", "species"
  add_foreign_key "marker_names", "marker_alias_details"
  add_foreign_key "marker_names", "markers"
  add_foreign_key "markers", "marker_sets"
  add_foreign_key "multi_maps", "scaffolds"
  add_foreign_key "multi_maps", "snps"
  add_foreign_key "mutations", "genes"
  add_foreign_key "mutations", "libraries"
  add_foreign_key "mutations", "snps"
  add_foreign_key "primers", "primer_types"
  add_foreign_key "primers", "snps"
  add_foreign_key "region_coverages", "libraries"
  add_foreign_key "region_coverages", "regions"
  add_foreign_key "region_scores", "regions"
  add_foreign_key "region_scores", "score_types", column: "score_types_id"
  add_foreign_key "regions", "scaffolds"
  add_foreign_key "scaffold_mappings", "scaffolds"
  add_foreign_key "scaffold_maps", "chromosomes"
  add_foreign_key "scaffold_maps", "genetic_maps"
  add_foreign_key "scaffold_maps", "scaffolds"
  add_foreign_key "scaffolds", "assemblies"
  add_foreign_key "snps", "scaffolds"
  add_foreign_key "snps", "species"
end
