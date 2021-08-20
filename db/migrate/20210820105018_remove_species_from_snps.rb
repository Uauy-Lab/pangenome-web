class RemoveSpeciesFromSnps < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :snps, :species
  end
end
