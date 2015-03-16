class CreateMapPositions < ActiveRecord::Migration
  def change
    create_table :map_positions do |t|

      t.timestamps null: false
    end
  end
end
