class AddMarkerSetId < ActiveRecord::Migration[6.0]
  def change
  	create_table :marker_sets do |t|
      t.string :name
      t.string :description	
      t.timestamps null: false
    end
  #	add_column(table_name, column_name, type, options)
  end
end
