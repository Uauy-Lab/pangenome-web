class AddSnpsAndScaffoldIndexToMultiMaps < ActiveRecord::Migration
  def change
  	 add_index :multi_maps, [:scaffold_id, :snp_id] , unique: true
  end
end
