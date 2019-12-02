class CreateRegionCoverages < ActiveRecord::Migration[6.0]
  def change
    create_table :region_coverages do |t|
      t.references :library, index: true
      t.references :region, index: true
      t.float :coverage
      t.string :hom,  limit: 1
      t.string :het,  limit: 1

      t.timestamps null: false
    end
    add_foreign_key :region_coverages, :libraries
    add_foreign_key :region_coverages, :regions
  end
end
