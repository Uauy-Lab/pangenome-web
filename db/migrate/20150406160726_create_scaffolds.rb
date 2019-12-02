class CreateScaffolds < ActiveRecord::Migration[6.0]
  def change
    create_table :scaffolds do |t|
      t.string :name
      t.integer :length
      t.timestamps null: false
    end

    create_table :scaffolds_markers, id: false do |t|
      t.belongs_to :scaffold, index: true
      t.belongs_to :marker, index: true
      t.float :identity
      t.integer :marker_start, index: true
      t.integer :marker_end
      t.string :marker_orientation, limit: 1
      t.integer :scaffold_start, index: true
      t.integer :scaffold_end
      t.string :scaffold_orientation, limit: 1
      t.string :sequence, limit: 500
    end
  end
end
