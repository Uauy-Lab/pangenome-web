class AddInReciprocalToHaplotypeBlocks < ActiveRecord::Migration[6.0]
  def change
    add_column :haplotype_blocks, :in_reciprocal, :boolean
  end
end
