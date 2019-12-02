class AddDecriptionToGenes < ActiveRecord::Migration[6.0]
  def change
    add_column :genes, :description, :text
  end
end
