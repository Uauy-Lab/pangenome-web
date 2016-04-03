class CreatePrimers < ActiveRecord::Migration
  def change
    create_table :primers do |t|
      t.references :snp, index: true
      t.references :primer_type, index: true
      t.string :orientation,  limit: 1
      t.string :wt
      t.string :alt
      t.string :common
      t.timestamps null: false
    end
    add_foreign_key :primers, :snps
    add_foreign_key :primers, :primer_types
  end
end