class AddIsPseudomoleculeToAssemblies < ActiveRecord::Migration[6.0]
  def change
  	add_column :assemblies, :is_pseudomolecule, :boolean, :default => false
  end
end
