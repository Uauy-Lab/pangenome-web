class AddProteinPositionToEffects < ActiveRecord::Migration[6.0]
  def change
    add_column :effects, :protein_position, :integer
  end
end
