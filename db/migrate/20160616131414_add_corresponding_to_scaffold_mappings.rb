class AddCorrespondingToScaffoldMappings < ActiveRecord::Migration
  def change
  	remove_foreign_key :scaffold_mappings, :corresponding
  	remove_reference :scaffold_mappings, :corresponding, index:true
  	add_column :scaffold_mappings, :other_coordinate, :integer
  	add_column :scaffold_mappings, :other_scaffold_id, :integer 

  end
end
