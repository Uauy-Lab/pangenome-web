class AddColumnToSnp < ActiveRecord::Migration
  def change
    add_reference :snps, :species, index: true
  	add_foreign_key :snps, :species
  	remove_index :snps, column: [:scaffold_id, :position, :wt, :alt] 
  	add_index :snps, [:scaffold_id, :species_id, :position, :wt, :alt] , :unique => true, :name => 'snp_species_index'
  end
end
