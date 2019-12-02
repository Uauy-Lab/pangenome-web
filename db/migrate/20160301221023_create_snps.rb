class CreateSnps < ActiveRecord::Migration[6.0]
  def change
    create_table :snps do |t|
      t.references :scaffold, index: true
      t.integer :position, index:true
      t.string :ref, :limit => 1
      t.string :wt, :limit => 1
      t.string :alt, :limit => 1

      t.timestamps null: false
    end
    add_foreign_key :snps, :scaffolds
  end
end
