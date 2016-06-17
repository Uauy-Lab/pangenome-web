class AddHomCorrectedToMutations < ActiveRecord::Migration
  def change
    add_column :mutations, :hom_corrected, :string,  limit: 1
  end
end
