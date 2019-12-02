class CreateGeneticMaps < ActiveRecord::Migration[6.0]
  def change
    create_table :genetic_maps do |t|
      t.string :name
      t.string :description	
      t.timestamps null: false
    end
  end
end
