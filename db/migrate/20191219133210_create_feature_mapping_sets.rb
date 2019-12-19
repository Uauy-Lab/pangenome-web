class CreateFeatureMappingSets < ActiveRecord::Migration[6.0]
  def change
    create_table :feature_mapping_sets do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
    add_index :feature_mapping_sets, :name
  end
end
