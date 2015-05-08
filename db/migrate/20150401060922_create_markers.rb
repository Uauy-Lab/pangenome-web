class CreateMarkers < ActiveRecord::Migration
  def change
    create_table :markers do |t|
      t.string :name
      t.belongs_to :positions, index:true
      t.timestamps null: false
      
    end
    
  end
end
