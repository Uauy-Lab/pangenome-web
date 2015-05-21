class CreateMarkerScaffoldAlignments < ActiveRecord::Migration
  def change
    create_table :marker_scaffold_alignments do |t|
      t.references :marker, index: true
      t.references :scaffold, index: true
      t.integer :marker_start, index:true
      t.integer :marker_end, index:true
      t.string :marker_oientation, limit: 1
      t.string :scaffold_start, index:true
      t.integer :scaffold_end, index:true
      t.string :scaffold_orientation, limit: 1
      t.decimal :identity, precision: 5, scale: 2, index:true
      

      t.timestamps null: false
    end
    add_foreign_key :marker_scaffold_alignments, :Markers
    add_foreign_key :marker_scaffold_alignments, :Scaffolds
  end
end
