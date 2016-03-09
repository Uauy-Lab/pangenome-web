class AddNameColumnToFeature < ActiveRecord::Migration
  def change
  	add_column :features, :name, :string,  index: true
  end
end
