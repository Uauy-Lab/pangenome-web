class AddHaplotypeSetToHaplotypeBlocks < ActiveRecord::Migration[6.0]
  def change
    add_reference :haplotype_blocks, :haplotype_set, null: false, foreign_key: true
  end
end
