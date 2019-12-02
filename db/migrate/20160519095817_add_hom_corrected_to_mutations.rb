class AddHomCorrectedToMutations < ActiveRecord::Migration[6.0]
  def change
    add_column :mutations, :hom_corrected, :string,  limit: 1
  end
end
