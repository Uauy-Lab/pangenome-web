class RemoveEffectColumnsFromMutation < ActiveRecord::Migration
  def change
    remove_foreign_key :mutations, :mutation_consequence    
    remove_reference :mutations, :mutation_consequence, index: true
    remove_column :mutations, :cdna_position, :integer
    remove_column :mutations, :cds_position, :integer
    remove_column :mutations, :amino_acids, :string
    remove_column :mutations, :codons, :string
    remove_column :mutations, :sift_score, :float
  end
end
