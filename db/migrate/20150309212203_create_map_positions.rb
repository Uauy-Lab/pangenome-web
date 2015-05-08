class CreateMapPositions < ActiveRecord::Migration
  def change
    create_table :map_positions do |t|
      t.integer :order
      t.float :centimorgan 	
      t.belongs_to :genetic_map, index:true
      t.belongs_to :marker, index:true
      t.belongs_to :chromosome, index:true
      t.timestamps null: false
    end
  end
end
