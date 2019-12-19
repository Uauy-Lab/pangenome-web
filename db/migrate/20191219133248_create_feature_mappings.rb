class CreateFeatureMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :feature_mappings do |t|
      t.references :assembly, null: false, foreign_key: true
      t.references :feature, null: false, foreign_key: true
      t.references :chromosome, null: false, foreign_key: true
      t.references :feature_mapping_set, null: false, foreign_key: true
      t.bigint :other_feature

      t.timestamps
    end
    add_foreign_key :feature_mappings, :feature_mapping_sets, column: :other_gene
  end
end
