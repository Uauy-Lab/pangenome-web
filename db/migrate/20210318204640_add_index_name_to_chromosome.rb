class AddIndexNameToChromosome < ActiveRecord::Migration[6.1]
  def change
  	add_index :chromosomes, :name
  	add_index :species, :name
  end
end
