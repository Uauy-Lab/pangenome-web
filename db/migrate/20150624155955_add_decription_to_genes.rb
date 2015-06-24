class AddDecriptionToGenes < ActiveRecord::Migration
  def change
    add_column :genes, :description, :text
  end
end
