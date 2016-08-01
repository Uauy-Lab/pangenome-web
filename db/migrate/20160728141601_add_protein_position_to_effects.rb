class AddProteinPositionToEffects < ActiveRecord::Migration
  def change
    add_column :effects, :protein_position, :integer
  end
end
