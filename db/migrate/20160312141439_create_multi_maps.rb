class CreateMultiMaps < ActiveRecord::Migration
  def change
    create_table :multi_maps do |t|
      t.references :snp, index: true
      t.references :scaffold, index: true

      t.timestamps null: false
    end
    add_foreign_key :multi_maps, :snps
    add_foreign_key :multi_maps, :scaffolds
  end
end
