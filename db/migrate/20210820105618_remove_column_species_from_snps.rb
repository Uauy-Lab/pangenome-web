class RemoveColumnSpeciesFromSnps < ActiveRecord::Migration[6.1]
  def change
    remove_reference :snps, :species
  end
end
