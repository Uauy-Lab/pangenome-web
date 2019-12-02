class CreateScaffoldMaps < ActiveRecord::Migration[6.0]
  def change
    create_table :scaffold_maps do |t|
      t.references :scaffold, index: true
      t.references :chromosome, index: true
      t.references :genetic_map, index: true
      t.float :cm

      t.timestamps null: false
    end
    add_index :scaffold_maps, :cm
    add_foreign_key :scaffold_maps, :scaffolds
    add_foreign_key :scaffold_maps, :chromosomes
    add_foreign_key :scaffold_maps, :genetic_maps
  end
end
