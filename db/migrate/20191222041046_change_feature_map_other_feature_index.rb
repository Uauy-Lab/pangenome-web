class ChangeFeatureMapOtherFeatureIndex < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :feature_mappings, :feature_mapping_sets, column: :other_feature
  	add_foreign_key :feature_mappings, :features, column: :other_feature
  end
end
