class AddDeletedScaffoldIndex < ActiveRecord::Migration[6.0]
  def change
  	 add_index :deleted_scaffolds, [:scaffold_id, :library_id] , unique: true
  end
end
