class CreateMutations < ActiveRecord::Migration[6.0]
  def change
    create_table :mutations do |t|
      t.references :scaffold, index: true
      t.references :chromosome, index: true
      t.string :library
      t.references :mutant_line, index: true
      t.integer :position
      t.string :ref_base
      t.string :wt_base
      t.string :alt_base
      t.string :het_hom
      t.integer :wt_cov
      t.integer :mut_cov
      t.string :confidence
      t.references :gene, index: true
      t.references :mutation_consequence, index: true
      t.integer :cdna_position
      t.integer :cds_position
      t.string :amino_acids
      t.string :codons
      t.float :sift_score

      t.timestamps null: false
    end
    add_foreign_key :mutations, :scaffolds
    add_foreign_key :mutations, :chromosomes
    add_foreign_key :mutations, :mutant_lines
    add_foreign_key :mutations, :genes
    add_foreign_key :mutations, :mutation_consequences
  end
end
