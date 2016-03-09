class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.references :scaffold, index: true
      t.integer :start
      t.integer :end

      t.timestamps null: false
    end
    add_foreign_key :regions, :scaffolds
    add_index :regions, [:scaffold_id, :start, :end] , unique: true
  end
end
