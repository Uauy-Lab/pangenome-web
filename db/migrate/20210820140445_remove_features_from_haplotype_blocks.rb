class RemoveFeaturesFromHaplotypeBlocks < ActiveRecord::Migration[6.1]
  def change
    remove_column :haplotype_blocks, :last_feature
    remove_column :haplotype_blocks, :first_feature
  end
end
