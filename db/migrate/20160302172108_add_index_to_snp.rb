class AddIndexToSnp < ActiveRecord::Migration[6.0]
  def change
    add_index :snps, [:scaffold_id, :position, :wt, :alt] , unique: true
  end
end
