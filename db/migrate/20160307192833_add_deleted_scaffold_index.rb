class AddDeletedScaffoldIndex < ActiveRecord::Migration
  def change
  	 add_index :deleted_scaffolds, [:scaffold_id, :library_id] , unique: true
  end
end
