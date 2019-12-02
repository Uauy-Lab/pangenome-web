class AddIndexesScaffolds < ActiveRecord::Migration[6.0]
  def change
  	add_index :scaffolds, :name
  	add_reference :scaffolds, :assembly, index: true, foreign_key: true
  end
end
