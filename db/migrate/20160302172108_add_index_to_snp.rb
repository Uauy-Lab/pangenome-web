class AddIndexToSnp < ActiveRecord::Migration
  def change
    add_index :snps, [:scaffold_id, :position, :wt, :alt] , unique: true
  end
end
