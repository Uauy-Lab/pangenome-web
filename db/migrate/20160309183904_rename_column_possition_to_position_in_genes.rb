class RenameColumnPossitionToPositionInGenes < ActiveRecord::Migration
  def change
  	rename_column :genes, :possition, :position
  end
end
