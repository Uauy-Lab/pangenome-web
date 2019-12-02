class AddNameColumnToFeature < ActiveRecord::Migration[6.0]
  def change
  	add_column :features, :name, :string,  index: true
  end
end
