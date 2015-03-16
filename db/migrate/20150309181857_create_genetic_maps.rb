class CreateGeneticMaps < ActiveRecord::Migration
  def change
    create_table :genetic_maps do |t|

      
      t.timestamps null: false
    end
  end
end
