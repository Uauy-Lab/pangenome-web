class AddColumnMrnaFeatureToGene < ActiveRecord::Migration[6.0]
  def change
  	add_reference :genes, :feature, index: true
  	add_foreign_key :genes, :features
  end
  
end
