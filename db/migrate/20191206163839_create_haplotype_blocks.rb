class CreateHaplotypeBlocks < ActiveRecord::Migration[6.0]
  def change
    create_table :haplotype_blocks do |t|
      t.integer :block_no
      t.references :region, foreign_key: true
      t.references :assembly, foreign_key: true
      t.bigint :first_feature
      t.bigint :last_feature

      t.timestamps
    end

    add_foreign_key :haplotype_blocks, :features, column: :first_feature
    add_foreign_key :haplotype_blocks, :features, column: :last_feature
  end
end
