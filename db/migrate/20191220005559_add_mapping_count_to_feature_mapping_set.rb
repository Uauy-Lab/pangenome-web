class AddMappingCountToFeatureMappingSet < ActiveRecord::Migration[6.0]
  def change
  	add_column :feature_mapping_sets, :mapping_count, :integer
  end
end
