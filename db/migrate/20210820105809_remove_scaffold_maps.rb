class RemoveScaffoldMaps < ActiveRecord::Migration[6.1]
  def change
    drop_table :scaffold_maps
    drop_table :scaffold_mappings
  end
end
