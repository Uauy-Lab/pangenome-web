class CreateScaffoldMappings < ActiveRecord::Migration
  def change
    create_table :scaffold_mappings do |t|
      t.references :scaffold, index: true
      t.integer :coordinate
      t.references :corresponding, index: true

      t.timestamps null: false
    end
    add_foreign_key :scaffold_mappings, :Scaffolds
    add_foreign_key :scaffold_mappings, :scaffold_mappings, column: :corresponding_id 
  end
end
