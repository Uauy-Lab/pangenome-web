class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.references :region, index: true
      t.references :feature_type, index: true
      t.references :biotype, index: true
      t.integer :parent_id
      t.string :orientation,  limit: 1
      t.integer :frame

      t.timestamps null: false
    end
    add_foreign_key :features, :regions
    add_foreign_key :features, :feature_types
    add_foreign_key :features, :biotypes
    add_foreign_key :features, :features, column: :parent_id
  end
end
