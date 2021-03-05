class RenameValueInRegionScore < ActiveRecord::Migration[6.1]
  def change
  	remove_column :region_scores, :vaule
  	add_column :region_scores, :value, :integer
  end
end
