class RenameColumnPossitionToPositionInGenes < ActiveRecord::Migration[6.0]
  def change
  	rename_column :genes, :possition, :position
  end
end
