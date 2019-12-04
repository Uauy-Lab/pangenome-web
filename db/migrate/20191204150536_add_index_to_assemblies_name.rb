class AddIndexToAssembliesName < ActiveRecord::Migration[6.0]
  def change
  	 add_index :assemblies, :name
  end
end
